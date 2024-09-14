//
//  OneEmailDetailsInteractor.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import Foundation
import UIKit

protocol OneEmailDetailsBusinessLogic {
    func onDidLoadViews(request: OneEmailDetailsFlow.OnDidLoadViews.Request)
    func markAsUnread(request: OneEmailDetailsFlow.OnEnvelopNavBarButton.Request)
    func didTapTrashNavBarIcon(request: OneEmailDetailsFlow.OnTrashNavBarIcon.Request)

    func didTapChevronAdresses(request: OneEmailDetailsFlow.OnChevronTapped.Request)
    func didTapAtFileOrFoto(request: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Request)
    func didTapDownloadIcon(request: OneEmailDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Request)
    func didTapQuattroIcon(request: OneEmailDetailsFlow.OnQuattroIcon.Request)

    func didTapReplyButton(request: OneEmailDetailsFlow.OnReplyButton.Request)
    func didTapReplyToAllButton(request: OneEmailDetailsFlow.OnReplyToAllButton.Request)
    func didTapForwardButton(request: OneEmailDetailsFlow.OnForwardButton.Request)
}


protocol OneEmailDetailsDataStore: AnyObject {
    var oneEmailMessage: EmailMessageModel? { get }
    var imageToOpen: UIImage { get }
    var fileSize: Int? { get }
    var fileData: Data? { get }
    var fileDataToSaveAtDownloadIcon: Data? { get }
    var fileNameWithExt: String { get }

    var incomingEmailUIDL: String { get }
    var emailType: NewEmailCreateModels.NewReOrFwdEmailType { get }
}


final class OneEmailDetailsInteractor: OneEmailDetailsBusinessLogic, OneEmailDetailsDataStore {

    // MARK: - Public properties

    var presenter: OneEmailDetailsPresentationLogic?
    var worker: OneEmailDetailsWorkingLogic?
    var oneEmailMessage: EmailMessageModel?

    var imageToOpen = UIImage()
    var fileSize: Int?
    var fileData: Data?
    var fileDataToSaveAtDownloadIcon: Data?
    var fileNameWithExt = String()

    var incomingEmailUIDL: String
    var emailType: NewEmailCreateModels.NewReOrFwdEmailType = .newEmail

    // MARK: - Private properties

    private var hasFotos = false
    private var isMoreAdressesToSendShown = false
    private var oneMailModel: EmailMessageWithNeededProperties?
    private var htmlInlineAttachments = [AttachmentModel]()
    private var messageTypeFromSideMenu: TabBarManager.MessageType


    // MARK: - Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(mailUIDL: String, messageTypeFromSideMenu: TabBarManager.MessageType) {
        self.incomingEmailUIDL = mailUIDL
        self.messageTypeFromSideMenu = messageTypeFromSideMenu
    }

    // MARK: - Public methods

    func onDidLoadViews(request: OneEmailDetailsFlow.OnDidLoadViews.Request) {
        observeThemeChanging()
        observeLangChanging()
        presenter?.presentWaitIndicator(response: OneEmailDetailsFlow.OnWaitIndicator.Response(isShow: true))

        worker?.getMail(byUIDL: incomingEmailUIDL) { [weak self] result in
            guard let self = self else { return }
            self.presenter?.presentWaitIndicator(response: OneEmailDetailsFlow.OnWaitIndicator.Response(isShow: false))

            switch result {
            case .success(let oneEmailMessage):
                Log.i("OneMailData got successfully")
                self.oneEmailMessage = oneEmailMessage

                var arrayOfAttachmentNamesAndDataPreviewable = [AttachmentModel]()
                //можно вынести в метод оба блока проверки
                for htmlInlineAttachment in oneEmailMessage.htmlInlineAttachments {
                    let fileExtension = htmlInlineAttachment.filename.components(separatedBy: ".").last ?? ""
                    if ImageManager.isFileImagePreviewable(fileExtension: fileExtension) {
                        arrayOfAttachmentNamesAndDataPreviewable.append(htmlInlineAttachment)
                    }
                }
                for attachment in oneEmailMessage.attachments {
                    let fileExtension = attachment.filename.components(separatedBy: ".").last ?? ""
                    if ImageManager.isFileImagePreviewable(fileExtension: fileExtension) {
                        arrayOfAttachmentNamesAndDataPreviewable.append(attachment)
                    }
                }
                if !arrayOfAttachmentNamesAndDataPreviewable.isEmpty {
                    self.hasFotos = true
                }

                var isAttachmentIconDisplaying = false
                if !oneEmailMessage.attachments.isEmpty {
                    isAttachmentIconDisplaying = true
                }
                let arrayOfAttachmentNamesAndExt = oneEmailMessage.attachments.map { $0.filename }

                // Интеграция содержимого вложений в HTML
                let updatedHtmlBody = self.embedInlineAttachments(in: oneEmailMessage.htmlBody, attachments: oneEmailMessage.htmlInlineAttachments)
                print("updatedHtmlBody - \(updatedHtmlBody)")

                oneMailModel = EmailMessageWithNeededProperties(
                    id: oneEmailMessage.id,
                    fromName: oneEmailMessage.from,
                    senderEmail: oneEmailMessage.sender,
                    to: oneEmailMessage.to,
                    cc: oneEmailMessage.cc.map({ "\($0.displayName) <\($0.mailbox)>" }).joined(separator: ", "),
                    subject: oneEmailMessage.subject,
                    body: updatedHtmlBody,
                    receivedDate: oneEmailMessage.date,
                    isAttachmentIconDisplaying: isAttachmentIconDisplaying,
                    arrayOfAttachmentNamesAndExt: arrayOfAttachmentNamesAndExt,
                    arrayOfAttachmentNamesAndDataPreviewable: arrayOfAttachmentNamesAndDataPreviewable,
                    hasFotos: self.hasFotos)

                if let oneMailModel = oneMailModel {
                    self.oneEmailMessage?.htmlBody = updatedHtmlBody

                    self.presenter?.presentUpdate(response: OneEmailDetailsFlow.Update.Response(
                        emailModelWithNeededProperties: oneMailModel,
                        shouldUpdateButtons: true,
                        htmlInlineAttachments: oneEmailMessage.htmlInlineAttachments,
                        messageTypeFromSideMenu: messageTypeFromSideMenu))
                }

            case .failure(let failure):
                Log.e(failure.localizedDescription)
                self.presenter?.presentAlert(response: OneEmailDetailsFlow.AlertInfo.Response(error: failure))
            }
        }
    }

//        func embedInlineAttachments(in htmlBody: String, attachments: [AttachmentModel]) -> String {
//            var updatedHtmlBody = htmlBody
//            
//            for attachment in attachments {
//                let base64String = attachment.content.base64EncodedString(options: .lineLength64Characters)
//                    let mimeType: String
//                    switch attachment.mimeType.lowercased() {
//                    case "image/png":
//                        mimeType = "image/png"
//                    case "image/jpeg":
//                        mimeType = "image/jpeg"
//                    default:
//                        mimeType = "application/octet-stream"
//                    }
//                    
//                    let dataUri = "data:\(mimeType);base64,\(base64String)"
//                    updatedHtmlBody = updatedHtmlBody.replacingOccurrences(of: "cid:\(attachment.filename)", with: dataUri)
//                
//            }
//            
//            return updatedHtmlBody
//        }

    private func embedInlineAttachments(in htmlBody: String, attachments: [AttachmentModel]) -> String {
        var updatedHtmlBody = htmlBody

        for attachment in attachments {
            let base64String = attachment.content.base64EncodedString(options: .lineLength64Characters)

            let fileExtension = attachment.filename.components(separatedBy: ".").last ?? ""
            let mimeType = MimeTypeManager.getMimeType(forExtension: fileExtension) ?? "application/octet-stream"

            let dataUri = "data:\(mimeType);base64,\(base64String)"
            updatedHtmlBody = updatedHtmlBody.replacingOccurrences(of: "cid:\(attachment.filename)", with: dataUri)
        }

        return updatedHtmlBody
    }

    
    #warning("зачем этот метод? - он нигде не вызывается(я не писал его)")
    private func createHtmlFileWithAttachments(htmlBody: String, attachments: [AttachmentModel]) -> URL? {
        let tempDirectory = NSTemporaryDirectory()
        let htmlFilePath = tempDirectory.appending("email.html")
        var updatedHtmlBody = htmlBody

        for attachment in attachments {
            let filePath = tempDirectory.appending(attachment.filename)
            let fileUrl = URL(fileURLWithPath: filePath)
            try? attachment.content.write(to: fileUrl)
            let relativePath = "file://\(filePath)"
            updatedHtmlBody = updatedHtmlBody.replacingOccurrences(of: "cid:\(attachment.filename)", with: relativePath)
        }

        try? updatedHtmlBody.write(toFile: htmlFilePath, atomically: true, encoding: .utf8)
        return URL(fileURLWithPath: htmlFilePath)
    }

    func didTapTrashNavBarIcon(request: OneEmailDetailsFlow.OnTrashNavBarIcon.Request) {
        if let oneEmailMessage = oneEmailMessage {
            self.worker?.deleteMail(oneEmailMessage.id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success():
                    Log.i("EmailMessage with \(oneEmailMessage.id) has been deleted successfully")

                    if messageTypeFromSideMenu != .deleted {
                        worker?.createFolder(name: GlobalConstants.deletedEmails) { result in
                            switch result {
                            case .success():
                                Log.i("Folder \(GlobalConstants.deletedEmails) has been created successfully")

                                self.worker?.addMail(oneEmailMessage, toFolder: GlobalConstants.deletedEmails) { result in
                                    switch result {
                                    case .success():
                                        Log.i("Mail has been added to folder \(GlobalConstants.deletedEmails) successfully")
                                        self.presenter?.presentRouteToMailStartScreen(response: OneEmailDetailsFlow.RoutePayload.Response())

                                    case .failure(let error):
                                        print("Failed to add email to folder \(GlobalConstants.deletedEmails), description: \(error.localizedDescription)")
                                    }
                                }
                            case .failure(let error):
                                print("Failed to create folder \(GlobalConstants.deletedEmails), description: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        self.presenter?.presentRouteToMailStartScreen(response: OneEmailDetailsFlow.RoutePayload.Response())
                    }
                case .failure(let error):
                    print("Failed to delete \(oneEmailMessage.id), description: \(error.localizedDescription)")
                }
            }
        }
    }


    func didTapChevronAdresses(request: OneEmailDetailsFlow.OnChevronTapped.Request) {
        if let oneMailModel = oneMailModel {
            presenter?.presentUpdate(response: OneEmailDetailsFlow.Update.Response(
                emailModelWithNeededProperties: oneMailModel,
                shouldUpdateButtons: false,
                htmlInlineAttachments: htmlInlineAttachments,
                messageTypeFromSideMenu: messageTypeFromSideMenu))
        }
    }

    //если в файле есть картинка - открывать на фуллСкрин,
    //если в файле нет картинки - открывать OpenData
    func didTapAtFileOrFoto(request: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Request) {
        if let image = request.fotoViewModel?.fotoImage { //tap at FotoCell
            imageToOpen = image
            fileNameWithExt = request.fotoViewModel?.fileNameWithExt.string ?? ""
            if ImageManager.isFileImagePreviewable(fileExtension: fileNameWithExt.components(separatedBy: ".").last ?? ""),
               let content = oneEmailMessage?.htmlInlineAttachments.first(where: { $0.filename == fileNameWithExt })?.content {
                fileSize = Int(Double(content.count) / 1024.0)
            }
            presenter?.presentRouteToFullScreenImage(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response())
        }

        if let nameAndExt = request.cloudEmailViewModel?.filenameWithExt { //tap at CloudAttachment and check is image inside to open FullScreenImage
            if ImageManager.isFileImagePreviewable(fileExtension: nameAndExt.components(separatedBy: ".").last ?? ""),
               let content = oneEmailMessage?.attachments.first(where: { $0.filename == nameAndExt })?.content,
               let image = UIImage(data: content) {
                imageToOpen = image
                fileNameWithExt = nameAndExt
                fileSize = Int(Double(content.count) / 1024.0)

                presenter?.presentRouteToFullScreenImage(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response())
            } else {
                fileNameWithExt = nameAndExt
                fileData = oneEmailMessage?.attachments.first(where: { $0.filename == nameAndExt })?.content
                presenter?.presentRouteToOpenData(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response())
            }
        }
    }

    func didTapDownloadIcon(request: OneEmailDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Request) {
        if let nameAndExt = request.fotoViewModel?.fileNameWithExt.string,
           let content = oneEmailMessage?.htmlInlineAttachments.first(where: { $0.filename == nameAndExt })?.content {
            fileDataToSaveAtDownloadIcon = content
            fileNameWithExt = nameAndExt

            presenter?.presentRouteToSaveDialog(response: OneEmailDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Response())
        }
    }

    func didTapQuattroIcon(request: OneEmailDetailsFlow.OnQuattroIcon.Request) {
        //presenter?...
    }

    func didTapReplyButton(request: OneEmailDetailsFlow.OnReplyButton.Request) {
        emailType = .reply
        presenter?.presentRouteToNewEmailCreate(
            response: OneEmailDetailsFlow.OnReplyButton.Response())
    }

    func didTapReplyToAllButton(request: OneEmailDetailsFlow.OnReplyToAllButton.Request) {
        emailType = .replyAll
        presenter?.presentRouteToNewEmailCreate(
            response: OneEmailDetailsFlow.OnReplyButton.Response())
    }

    func didTapForwardButton(request: OneEmailDetailsFlow.OnForwardButton.Request) {
        emailType = .forward
        presenter?.presentRouteToNewEmailCreate(
            response: OneEmailDetailsFlow.OnReplyButton.Response())
    }

    func markAsUnread(request: OneEmailDetailsFlow.OnEnvelopNavBarButton.Request) {
        Log.i("Selected email with id: \(oneEmailMessage?.id ?? "")")
        worker?.updateIsRead(id: oneEmailMessage?.id ?? "",
                             isRead: false,
                             completion: { [weak self] result in
            switch result {
            case .success(_):
//                self?.markLocalAsRead(id: request.id)
//               here could be alert (not yet)
                ()
            case .failure(let failure):
                Log.e("mark as read id \(self?.oneEmailMessage?.id ?? "") \(failure.localizedDescription)")
            }
        })
    }


    //MARK: - Private methods
//    private func markLocalAsRead(id: String) {
//        guard let index = mailsFromDatabase.firstIndex(where: { $0.id == id }) else { return }
//        mailsFromDatabase[index].isNewEmailIconDisplaying = false
//    }
    ///Light or Dark theme
    private func observeThemeChanging() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.screenThemeWasChanged,
            object: nil, queue: nil) { [weak self] _ in
                guard let self else {return}

                if let oneMailModel = oneMailModel {
                    self.presenter?.presentUpdate(response: OneEmailDetailsFlow.Update.Response(
                        emailModelWithNeededProperties: oneMailModel,
                        shouldUpdateButtons: true,
                        htmlInlineAttachments: htmlInlineAttachments,
                        messageTypeFromSideMenu: messageTypeFromSideMenu))
                }
            }
    }

    ///Light or Dark theme
    private func observeLangChanging() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.languageWasChangedNotification,
            object: nil, queue: nil) { [weak self] _ in
                guard let self else {return}
                if let oneMailModel = oneMailModel {
                    self.presenter?.presentUpdate(response: OneEmailDetailsFlow.Update.Response(
                        emailModelWithNeededProperties: oneMailModel,
                        shouldUpdateButtons: true,
                        htmlInlineAttachments: htmlInlineAttachments,
                        messageTypeFromSideMenu: messageTypeFromSideMenu))
                }
            }
    }
}
