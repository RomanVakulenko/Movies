//
//  OneEmailDetailsPresenter.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import UIKit
import DifferenceKit

protocol OneEmailDetailsPresentationLogic {
    func presentUpdate(response: OneEmailDetailsFlow.Update.Response)
    func presentWaitIndicator(response: OneEmailDetailsFlow.OnWaitIndicator.Response)
    func presentAlert(response: OneEmailDetailsFlow.AlertInfo.Response)

    func presentRouteToFullScreenImage(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response)
    func presentRouteToOpenData(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response)

    func presentRouteToMailStartScreen(response: OneEmailDetailsFlow.RoutePayload.Response)
    func presentRouteToSaveDialog(response: OneEmailDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Response)
    func presentRouteToNewEmailCreate(response: OneEmailDetailsFlow.OnReplyButton.Response)
}


final class OneEmailDetailsPresenter: OneEmailDetailsPresentationLogic {

    enum Constants {
        static let estimatedStackWidth: CGFloat = 16 + 45 + 8 + 2 + 16 + 16 //space for stack
        static let mainImageWidthHeight: CGFloat = 45
        static let leftRightInset: CGFloat = 8
        static let insideCellSpacingAndBorderWidth: CGFloat = 4
        static let iconExtWidth: CGFloat = 12
    }

    // MARK: - Public properties

    weak var viewController: OneEmailDetailsDisplayLogic?

    // MARK: - Public methods
    func presentRouteToOpenData(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToOpenData(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToFullScreenImage(response: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToOpenImage(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToMailStartScreen(response: OneEmailDetailsFlow.RoutePayload.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToMailStartScreen(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToSaveDialog(response: OneEmailDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToSaveDialog(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToNewEmailCreate(response: OneEmailDetailsFlow.OnReplyButton.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToNewEmailCreate(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel())
        }
    }


    func presentUpdate(response: OneEmailDetailsFlow.Update.Response) {
        let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
        let navBarTitle = TabBarManager.makeTitleImageAndSelectedImageForTabItem(messageType: response.messageTypeFromSideMenu).0
        let title = NSMutableAttributedString(
            string: navBarTitle,
            attributes: Theme.shared.isLight ? UIHelper.Attributed.blackStrongLRobotoMedium18 : UIHelper.Attributed.whiteStrongRobotoMedium18)

        var views: [AnyDifferentiable] = []

        let group = DispatchGroup()
        group.enter()
        self.makeUpperVMWith(oneEmailModel: response.emailModelWithNeededProperties) { upperView in
            views.append(upperView)
            group.leave()
        }

        group.notify(queue: DispatchQueue.global()) { [weak self] in
            guard let self = self else { return }
            if response.emailModelWithNeededProperties.isAttachmentIconDisplaying == true,
               let namesOfAttachedFiles = response.emailModelWithNeededProperties.arrayOfAttachmentNamesAndExt {
                views.append(makeAttachmentVM(fileNamesWithExt: namesOfAttachedFiles))
            }

            if response.shouldUpdateButtons {
                views.append(makeReplyReplyToAllForwardButtonsVM())
            }

            var viewModelsOfCells: [AnyDifferentiable] = []
            viewModelsOfCells.append(makeWebViewVM(htmlString: response.emailModelWithNeededProperties.body,
                                                   htmlInlineAttachments: response.htmlInlineAttachments)) //for use in production

            if response.emailModelWithNeededProperties.hasFotos == true {
                viewModelsOfCells.append(makeSeparatorCellVM())
                viewModelsOfCells.append(makeFotoCellTitleVM())

                if let attachmentsWithFotos = response.emailModelWithNeededProperties.arrayOfAttachmentNamesAndDataPreviewable {
                    viewModelsOfCells.append(contentsOf: makeFotoCellVM(attachmentsWithFotos: attachmentsWithFotos))
                }
            }

            let separatorColor = Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD

            let swipeInstructionText = NSAttributedString(
                string: getString(.oneEmailDetailsSwipeInstruction),
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular12 : UIHelper.Attributed.grayRegularDRobotoRegular12)

            let trashNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.trashNavBarIcon16x22L : UIHelper.Image.trashNavBarIcon16x22D)
            let unreadNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.unreadNavBarIcon20x16L : UIHelper.Image.unreadNavBarIcon20x16D)
            let menuNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.threeDotsNavBarIcon4x16L : UIHelper.Image.threeDotsNavBarIcon4x16D)

            let navBar = CustomNavBar(title: title,
                                      isLeftBarButtonEnable: true,
                                      isLeftBarButtonCustom: false,
                                      leftBarButtonCustom: nil,
                                      rightBarButtons: [menuNavBarIcon, unreadNavBarIcon, trashNavBarIcon])

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.displayUpdate(viewModel: OneEmailDetailsFlow.Update.ViewModel(
                    navBarBackground: backColor,
                    backViewColor: backColor,
                    navBar: navBar,
                    separatorColor: separatorColor,
                    hasAttachment: response.emailModelWithNeededProperties.isAttachmentIconDisplaying ?? false,
                    hasFotos: response.emailModelWithNeededProperties.hasFotos,
                    views: views,
                    items: viewModelsOfCells,
                    swipeInstructionTextLabel: swipeInstructionText)
                )
            }
        }
    }


    func presentAlert(response: OneEmailDetailsFlow.AlertInfo.Response) {
        let title = getString(.error)
        let text = response.error.localizedDescription
        let buttonTitle = getString(.closeAction)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(
                viewModel: OneEmailDetailsFlow.AlertInfo.ViewModel(title: title,
                                                                   text: text,
                                                                   buttonTitle: buttonTitle))
        }
    }

    func presentWaitIndicator(response: OneEmailDetailsFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: OneEmailDetailsFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
        }
    }

    // MARK: - Private methods
    private func makeUpperVMWith(oneEmailModel: EmailMessageWithNeededProperties,
                                 completion: @escaping (AnyDifferentiable) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD

            let title = NSAttributedString(
                string: oneEmailModel.subject,
                attributes: Theme.shared.isLight ? UIHelper.Attributed.blackMiddleLRobotoSemibold20 : UIHelper.Attributed.whiteStrongRobotoSemibold20)
            let subTitleReceived = NSAttributedString(
                string: getString(.oneEmailDetailsUpperViewReceivedSubTitle),
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.whiteDarkDRobotoRegular14)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy, HH:mm" //"12 сентября 2023, 12:35"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let dateTimeSubTitle = dateFormatter.string(from: oneEmailModel.receivedDate)

            let dateAttributedString = NSAttributedString(
                string: dateTimeSubTitle,
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.whiteDarkDRobotoRegular14)


            var attachmentIcon = UIImage()
            if oneEmailModel.isAttachmentIconDisplaying == true {
                attachmentIcon = UIHelper.Image.emailAttachmentIcon
            }

            let backColorOfImage = Alphabet.colorOfFirstLetter(in: oneEmailModel.fromName ?? "")
            let char = String((oneEmailModel.fromName ?? "").prefix(1))

            var avatarImage = UIImage()
            let semaphore = DispatchSemaphore(value: 0)
            ImageManager.createIcon(for: char,
                                    backCellViewColor: backColor,
                                    backColorOfImage: backColorOfImage,
                                    width: Constants.mainImageWidthHeight,
                                    height: Constants.mainImageWidthHeight) { image in
                avatarImage = image ?? UIImage()
                semaphore.signal()
            }
            semaphore.wait()

            var attibutedFromTitleAndAdress = NSMutableAttributedString()
            attibutedFromTitleAndAdress = makeAttributedTextTitleAndAdresses(
                title: getString(.oneEmailDetailsUpperViewFromTitle),
                array: [oneEmailModel.senderEmail])


            var attibutedToTitleAndAdressess = NSMutableAttributedString()
            if let recipientEmailAddress = oneEmailModel.to {
                attibutedToTitleAndAdressess = makeAttributedTextTitleAndAdresses(
                    title: getString(.oneEmailDetailsUpperViewToTitle),
                    array: [recipientEmailAddress])
            }
            let neededLinesForAllAdresses = calculateNeededNumberOfLines(attributedString: attibutedToTitleAndAdressess)

            let didSendTitle = NSAttributedString(
                string: getString(.oneEmailDetailsUpperViewDidSendTitle),
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06LRobotoSemiBold14 : UIHelper.Attributed.whiteDarkDRobotoSemiBold14)

            let didReceiveTitle = NSAttributedString(
                string: getString(.oneEmailDetailsUpperViewDidReceiveTitle),
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06LRobotoSemiBold14 : UIHelper.Attributed.whiteDarkDRobotoSemiBold14)

            let separatorColor = Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD

            let upperVM = OneEmailDetailsUpperModel.ViewModel(
                id: 0,
                backColor: backColor,
                oneEmailTitle: title,
                subTitleReceived: subTitleReceived,
                dateTimeSubTitle: dateAttributedString,
                hasAttachments: oneEmailModel.isAttachmentIconDisplaying ?? false,
                attachmentIcon: attachmentIcon,
                mainImage: avatarImage,
                fromTitleAndAdress: attibutedFromTitleAndAdress,
                toTitleAndAdresses: attibutedToTitleAndAdressess,
                neededLinesForAllAdresses: neededLinesForAllAdresses,
                didSendTitle: didSendTitle,
                dateTimeDidSend: dateAttributedString,
                didReceiveTitle: didReceiveTitle,
                dateTimeDidReceive: dateAttributedString,
                separatorColor: separatorColor,
                insets:  UIEdgeInsets(top: UIHelper.Margins.medium8px, //16 in figma is too much in fact
                                      left: UIHelper.Margins.medium16px,
                                      bottom: 0,
                                      right: UIHelper.Margins.medium16px)
            )
            //            return AnyDifferentiable(upperVM)
            completion(AnyDifferentiable(upperVM))
        }
    }

    // MARK: - Attachments

    private func makeOneAttachmentVM(fileNameWithExt: String,
                                     cloudBackColor: UIColor,
                                     attributesForString: [NSAttributedString.Key : Any]) -> (AnyDifferentiable, CGFloat) {

        let nameWithoutExtension = fileNameWithExt.components(separatedBy: ".").first ?? ""
        let name = NSAttributedString(string: nameWithoutExtension, attributes: attributesForString)
        var textLenght = CGFloat()

        if fileNameWithExt.count > GlobalConstants.cloudAttachmentTextLength20Сhars {
            textLenght = GlobalConstants.cloudAttachmentTextWidthPoints
        } else {
            textLenght = CGFloat(name.size().width)
        }
        let oneCellWidht = (Constants.leftRightInset * 2) + Constants.iconExtWidth + Constants.insideCellSpacingAndBorderWidth + textLenght

        let fileExtension = fileNameWithExt.components(separatedBy: ".").last ?? ""
        let iconOfFileExtension = ImageManager.getFileIcon(for: fileExtension)

        let attachmentsVM = CloudEmailAttachmentViewModel(
            id: fileNameWithExt,
            filenameWithoutExt: name,
            filenameWithExt: fileNameWithExt,
            backColor: cloudBackColor,
            borderColor: Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD,
            attachmentIconOfCloud: iconOfFileExtension,
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        return (AnyDifferentiable(attachmentsVM), oneCellWidht)
    }

    private func makeAttachmentVM(fileNamesWithExt: [String]) -> AnyDifferentiable {
        let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
        let title = NSAttributedString(
            string: getString(.oneEmailDetailsAttachedFilesTitle),
            attributes: Theme.shared.isLight ? UIHelper.Attributed.blackMiddleLRobotoSemiBold14 : UIHelper.Attributed.whiteStrongRobotoSemiBold14)
        let attributesForAttachmentName = Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.grayRegularDRobotoRegular14

        var collectionOfAttachments: [AnyDifferentiable] = []
        var widthsOfAttachmentsFileNames = [CGFloat]()

        for nameWithExt in fileNamesWithExt {
            let (oneAttachmentCell, width) = makeOneAttachmentVM(
                fileNameWithExt: nameWithExt,
                cloudBackColor: backColor,
                attributesForString: attributesForAttachmentName)

            collectionOfAttachments.append(oneAttachmentCell)
            widthsOfAttachmentsFileNames.append(width)
        }

        let attachmentVM = OneEmailAttachmentViewModel(
            id: 0,
            backColor: backColor,
            attachmentTitle: title,
            insets:  UIEdgeInsets(top: UIHelper.Margins.medium8px,
                                  left: UIHelper.Margins.medium16px,
                                  bottom: UIHelper.Margins.medium8px,
                                  right: UIHelper.Margins.medium16px),
            items: collectionOfAttachments,
            widths: widthsOfAttachmentsFileNames)

        return AnyDifferentiable(attachmentVM)
    }


    private func makeWebViewVM(htmlString: String, htmlInlineAttachments: [AttachmentModel]) -> AnyDifferentiable {
        let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD

        let webViewCellVM = CellWithWKWebViewViewModel(
            id: 1,
            backColor: backColor,
            isUserInteractionEnabled: true,
            showsVerticalScrollIndicator: false,
            insets: UIEdgeInsets(top: UIHelper.Margins.small4px,
                                 left: UIHelper.Margins.medium16px,
                                 bottom: UIHelper.Margins.medium16px,
                                 right: UIHelper.Margins.medium16px),
            htmlString: htmlString,
            htmlInlineAttachments: htmlInlineAttachments) //needed if will be displayed in webView (not yet)

        return AnyDifferentiable(webViewCellVM)
    }


    private func makeSeparatorCellVM() -> AnyDifferentiable {
        let separatorColor = Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD
        let separatorCellVM = SeparatorCellViewModel(
            id: 0,
            separatorColor: separatorColor,
            insets: UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0))
        return AnyDifferentiable(separatorCellVM)
    }

    private func makeFotoCellTitleVM() -> AnyDifferentiable {
        let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD

        let title = NSAttributedString(
            string: getString(.oneEmailAttachedFotoTitle),
            attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.whiteDarkDRobotoRegular14)

        let fotoTextCellVM = TextFieldCellViewModel(
            id: 1,
            text: title,
            backColor: backColor,
            insets: UIEdgeInsets(top: UIHelper.Margins.medium8px,
                                 left: UIHelper.Margins.medium16px,
                                 bottom: 0,
                                 right: UIHelper.Margins.medium16px)
        )
        return AnyDifferentiable(fotoTextCellVM)
    }

    private func makeFotoCellVM(attachmentsWithFotos: [AttachmentModel]) -> [AnyDifferentiable] {
        let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
        let downloadIcon = Theme.shared.isLight ? UIHelper.Image.oneEmailDetailsDownloadL : UIHelper.Image.oneEmailDetailsDownloadD
        let quattroIcon = Theme.shared.isLight ? UIHelper.Image.oneEmailDetailsQuattroL :UIHelper.Image.oneEmailDetailsQuattroD
        let separatorAndBorderColor = Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD

        var fotoCellVMs: [AnyDifferentiable] = [] //[] to silence warning of return AnyDifferentiable

        for (id, attachmentModel) in attachmentsWithFotos.enumerated() {
            let fileExtension = attachmentModel.filename.components(separatedBy: ".").last ?? ""
            let iconOfFileExtension = ImageManager.getFileIcon(for: fileExtension)

            let name = NSAttributedString(
                string: attachmentModel.filename,
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.grayRegularDRobotoRegular14)

            let image = UIImage(data: attachmentModel.content) ?? UIImage()
            let fotoCellVM = FotoCellViewModel(id: id,
                                               backColor: backColor,
                                               borderColor: separatorAndBorderColor,
                                               fotoImage: image,
                                               fileIcon: iconOfFileExtension,
                                               fileName: name,
                                               downloadIcon: downloadIcon,
                                               quattroIcon: quattroIcon,
                                               insets: UIEdgeInsets(
                                                top: UIHelper.Margins.medium8px,
                                                left: UIHelper.Margins.medium16px,
                                                bottom: 0,
                                                right: UIHelper.Margins.medium16px))
            fotoCellVMs.append(AnyDifferentiable(fotoCellVM))

        }
        return fotoCellVMs
    }

    private func makeReplyReplyToAllForwardButtonsVM() -> AnyDifferentiable {
        //reply
        let attachmentReply = NSTextAttachment()
        attachmentReply.image = UIHelper.Image.oneEmailDetailsReply
        attachmentReply.bounds = CGRect(x: 0,
                                        y: -UIHelper.Margins.small2px,
                                        width: UIHelper.Margins.medium16px,
                                        height: UIHelper.Margins.medium16px)
        let attachmentStringReply = NSAttributedString(attachment: attachmentReply)
        let replyMutableAttributedString = NSMutableAttributedString(
            string: getString(.reply) + " ",
            attributes: UIHelper.Attributed.whiteRobotoMedium14)
        replyMutableAttributedString.append(attachmentStringReply)

        //replyToAll
        let attachmentReplyToAll = NSTextAttachment()
        attachmentReplyToAll.image = UIHelper.Image.oneEmailDetailsReplyToAll
        attachmentReplyToAll.bounds = CGRect(x: 0,
                                             y: -UIHelper.Margins.small2px,
                                             width: UIHelper.Margins.medium16px,
                                             height: UIHelper.Margins.medium16px)
        let attachmentStringReplyToAll = NSAttributedString(attachment: attachmentReplyToAll)
        let replyToAllMutableAttributedString = NSMutableAttributedString(
            string: getString(.replyToAll) + " ",
            attributes: UIHelper.Attributed.blueRobotoMedium14)
        replyToAllMutableAttributedString.append(attachmentStringReplyToAll)

        //forward
        let attachmentForward = NSTextAttachment()
        attachmentForward.image = UIHelper.Image.oneEmailDetailsForward
        attachmentForward.bounds = CGRect(x: 0,
                                          y: -UIHelper.Margins.small2px,
                                          width: UIHelper.Margins.medium16px,
                                          height: UIHelper.Margins.medium16px)
        let attachmentStringForward = NSAttributedString(attachment: attachmentForward)
        let forwardMutableAttributedString = NSMutableAttributedString(
            string: getString(.forward) + " ",
            attributes: UIHelper.Attributed.blueRobotoMedium14)
        forwardMutableAttributedString.append(attachmentStringForward)

        let backViewColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
        let backForwardColor = Theme.shared.isLight ? UIHelper.Color.whiteStrong : UIHelper.Color.almostBlackD
        let borderColor = UIHelper.Color.blue

        let makeReplyReplyToAllForwardButtonsVM = OneEmailDetailsButtonsViewModel(
            id: 1,
            replyTitle: replyMutableAttributedString,
            replyBackColor: UIHelper.Color.blue,
            replyImage: UIHelper.Image.oneEmailDetailsReply,

            replyToAllTitle: replyToAllMutableAttributedString,
            replyToAllBackColor: backViewColor,
            replyToAllImage: UIHelper.Image.oneEmailDetailsReplyToAll,
            borderColor: borderColor,

            forwardTitle: forwardMutableAttributedString,
            forwardBackColor: backForwardColor,
            forwardImage: UIHelper.Image.oneEmailDetailsForward,
            insets: UIEdgeInsets(top: UIHelper.Margins.medium8px,
                                 left: UIHelper.Margins.medium16px,
                                 bottom: UIHelper.Margins.medium8px,
                                 right: UIHelper.Margins.medium16px)
        )
        return AnyDifferentiable(makeReplyReplyToAllForwardButtonsVM)
    }


    // MARK: - makeAttributedTextTitleAndAdresses

    private func makeAttributedTextTitleAndAdresses(title: String, array: [String]) -> NSMutableAttributedString {
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06LRobotoSemiBold14 : UIHelper.Attributed.whiteDarkDRobotoSemiBold14)

        let allCombinedAttributedEmailsAndCommas = NSMutableAttributedString()
        allCombinedAttributedEmailsAndCommas.append(attributedTitle)

        for email in array {
            let attributedOneEmail = NSAttributedString(
                string: email,
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.whiteDarkDRobotoRegular14)
            let attrinbutedComma = NSAttributedString(
                string: ", ", //TODO make text and comma together (don't separate them)
                attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.whiteDarkDRobotoRegular14)

            allCombinedAttributedEmailsAndCommas.append(attributedOneEmail)
            allCombinedAttributedEmailsAndCommas.append(attrinbutedComma)
        }
        return allCombinedAttributedEmailsAndCommas
    }


    private func calculateNeededNumberOfLines(attributedString: NSAttributedString) -> Int {
        let titleAndAdressesLenght = CGFloat(attributedString.length)
        return Int(ceil(titleAndAdressesLenght / Constants.estimatedStackWidth))
    }
}

//
//let mockJsonOneEmailData = """
//        {
//            "backColor": "#FF0000",
//            "oneEmailTitle": "Test Email",
//            "subTitleReceived": "Received",
//            "dateTimeSubTitle": "2023-03-21 10:30:00",
//            "attachmentIcon": "data:image/png;base64,iVBORw0KGg...",
//            "avatarImage": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQPDxAQEB...",
//            "fromTitleAndAddress": "John Doe <johndoe@example.com>",
//            "chevronOpenCloseMoreAdresses": "data:image/png;base64,iVBORw0KGg...",
//            "toTitleAndAddresses": "Jane Doe <janedoe@example.com>",
//            "neededLinesForAllAdresses": 2,
//            "didSendTitle": "Sent",
//            "dateTimeDidSend": "2023-03-21 10:29:00",
//            "didReceiveTitle": "Received",
//            "dateTimeDidReceive": "2023-03-21 10:30:00"
//        }
//        """
