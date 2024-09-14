//
//  OneEmailDetailsController.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import UIKit
import SnapKit

protocol OneEmailDetailsDisplayLogic: AnyObject {
    func displayUpdate(viewModel: OneEmailDetailsFlow.Update.ViewModel)
    func displayWaitIndicator(viewModel: OneEmailDetailsFlow.OnWaitIndicator.ViewModel)
    func displayAlert(viewModel: OneEmailDetailsFlow.AlertInfo.ViewModel)
    func displayRouteToOpenImage(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel)

    func displayRouteToMailStartScreen(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel)
    func displayRouteToSaveDialog(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel)
    func displayRouteToOpenData(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel)

    func displayRouteToNewEmailCreate(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel)
}


// MARK: - OneEmailDetailsController

final class OneEmailDetailsController: UIViewController, NavigationBarControllable, FileShareable, AlertDisplayable {

    var interactor: OneEmailDetailsBusinessLogic?
    var router: (OneEmailDetailsRoutingLogic & OneEmailDetailsDataPassing)?

    lazy var contentView: OneEmailDetailsViewLogic = OneEmailDetailsView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.shared.isLight ? .darkContent : .lightContent
    }

    // MARK: - Private methods

    private var didNavBarSet = false

    // MARK: - Lifecycle
    
    override func loadView() {
        contentView.output = self
        view = contentView
        hideNavigationBar(animated: false) //to hide flashing blue "< Back"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        interactor?.onDidLoadViews(request: OneEmailDetailsFlow.OnDidLoadViews.Request())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didNavBarSet == true {
            showNavigationBar(animated: false)
        }
    }

    // MARK: - Public methods



    func leftNavBarButtonDidTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    func rightNavBarButtonTapped(index: Int) {
        switch index {
        case 0:
            ()
        case 1:
            interactor?.markAsUnread(request: OneEmailDetailsFlow.OnEnvelopNavBarButton.Request())
        case 2:
            interactor?.didTapTrashNavBarIcon(request: OneEmailDetailsFlow.OnTrashNavBarIcon.Request())
        default: return
        }
    }

    // MARK: - Private methods
    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() { }

    private func configureConstraints() { }
}

// MARK: - OneEmailDetailsDisplayLogic

extension OneEmailDetailsController: OneEmailDetailsDisplayLogic {

    func displayRouteToOpenData(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToOpenData()
    }

    func displayRouteToMailStartScreen(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToMailStartScreen()
    }

    func displayRouteToSaveDialog(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToSaveDialog()
    }

    ///If photo - task router to show it
    func displayRouteToOpenImage(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToOpenImage()
    }

    func displayRouteToNewEmailCreate(viewModel: OneEmailDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToNewEmailCreate()
    }

    func displayUpdate(viewModel: OneEmailDetailsFlow.Update.ViewModel) {
        if didNavBarSet == false {
            configureNavigationBar(navBar: viewModel.navBar)
            showNavigationBar(animated: false)
            didNavBarSet = true
        }
        setNeedsStatusBarAppearanceUpdate()
        contentView.update(viewModel: viewModel)
    }

    func displayWaitIndicator(viewModel: OneEmailDetailsFlow.OnWaitIndicator.ViewModel) {
        contentView.displayWaitIndicator(viewModel: viewModel)
    }

    func displayAlert(viewModel: OneEmailDetailsFlow.AlertInfo.ViewModel) {
        showAlert(title: viewModel.title,
                  message: viewModel.text,
                  firstButtonTitle: viewModel.buttonTitle ?? "Ok")
    }
}

// MARK: - OneEmailDetailsViewOutput

extension OneEmailDetailsController: OneEmailDetailsViewOutput {
    func didTapAtXButtonAtCloudAttachment(_ viewModel: CloudEmailAttachmentViewModel) { }


    func chevronOpenCloseAddressesTapped() {
        interactor?.didTapChevronAdresses(request: OneEmailDetailsFlow.OnChevronTapped.Request())
    }

    // MARK: CloudEmailAttachmentOutput
    func didTapAtCloudAttachment(_ viewModel: CloudEmailAttachmentViewModel){
        interactor?.didTapAtFileOrFoto(request: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Request(cloudEmailViewModel: viewModel))
    }

    // MARK: FotoOutput
    func didTapAtFoto(_ viewModel: FotoCellViewModel) {
        interactor?.didTapAtFileOrFoto(request: OneEmailDetailsFlow.OnAttachedFileOrImageTapped.Request(fotoViewModel: viewModel))
    }

    func didTapAtDownloadIcon(_ viewModel: FotoCellViewModel) {
        interactor?.didTapDownloadIcon(request: OneEmailDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Request(fotoViewModel: viewModel))
    }

    func didTapAtQuattroIcon(_ viewModel: FotoCellViewModel) {
        interactor?.didTapQuattroIcon(request: OneEmailDetailsFlow.OnQuattroIcon.Request())
    }

    // MARK: ButtonsOutput
    func didTapReply(viewModel: OneEmailDetailsButtonsViewModel.ButtonType) {
        interactor?.didTapReplyButton(request: OneEmailDetailsFlow.OnReplyButton.Request())
    }

    func didTapReplyToAll(viewModel: OneEmailDetailsButtonsViewModel.ButtonType) {
        interactor?.didTapReplyToAllButton(request: OneEmailDetailsFlow.OnReplyToAllButton.Request())
    }

    func didTapForward(viewModel: OneEmailDetailsButtonsViewModel.ButtonType) {
        interactor?.didTapForwardButton(request: OneEmailDetailsFlow.OnForwardButton.Request())
    }
}


