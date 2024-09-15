//
//  OneFilmDetailsPresenter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import DifferenceKit

protocol OneFilmDetailsPresentationLogic {
    func presentUpdate(response: OneFilmDetailsFlow.Update.Response)
    func presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response)
    func presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response)

    func presentRouteBack(response: OneFilmDetailsFlow.RoutePayload.Response)
}


final class OneFilmDetailsPresenter: OneFilmDetailsPresentationLogic {

    enum Constants {
        static let estimatedStackWidth: CGFloat = 16 + 45 + 8 + 2 + 16 + 16 //space for stack
        static let mainImageWidthHeight: CGFloat = 45
        static let leftRightInset: CGFloat = 8
        static let insideCellSpacingAndBorderWidth: CGFloat = 4
        static let iconExtWidth: CGFloat = 12
    }

    // MARK: - Public properties

    weak var viewController: OneFilmDetailsDisplayLogic?

    // MARK: - Public methods
    func presentRouteBack(response: OneFilmDetailsFlow.OnAttachedFileOrImageTapped.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToOpenData(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel())
        }
    }

    func presentUpdate(response: OneFilmDetailsFlow.Update.Response) {
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
                self?.viewController?.displayUpdate(viewModel: OneFilmDetailsFlow.Update.ViewModel(
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


    func presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response) {
        let title = getString(.error)
        let text = response.error.localizedDescription
        let buttonTitle = getString(.closeAction)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(
                viewModel: OneFilmDetailsFlow.AlertInfo.ViewModel(title: title,
                                                                   text: text,
                                                                   buttonTitle: buttonTitle))
        }
    }

    func presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
        }
    }

    // MARK: - Private methods

    private func makeCellForCollection(fileNameWithExt: String,
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

    private func makeCollectionVM(fileNamesWithExt: [String]) -> AnyDifferentiable {
        let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
        let title = NSAttributedString(
            string: getString(.oneEmailDetailsAttachedFilesTitle),
            attributes: Theme.shared.isLight ? UIHelper.Attributed.blackMiddleLRobotoSemiBold14 : UIHelper.Attributed.whiteStrongRobotoSemiBold14)
        let attributesForAttachmentName = Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.grayRegularDRobotoRegular14

        var collectionOfAttachments: [AnyDifferentiable] = []
        var widthsOfAttachmentsFileNames = [CGFloat]()

        for nameWithExt in fileNamesWithExt {
            let (oneAttachmentCell, width) = makeCellForCollection(
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


}
