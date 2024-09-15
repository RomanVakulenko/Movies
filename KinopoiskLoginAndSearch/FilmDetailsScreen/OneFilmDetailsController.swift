//
//  OneFilmDetailsController.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol OneFilmDetailsDisplayLogic: AnyObject {
    func displayUpdate(viewModel: OneFilmDetailsFlow.Update.ViewModel)
    func displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel)
    func displayAlert(viewModel: OneFilmDetailsFlow.AlertInfo.ViewModel)
    func displayRouteToOpenImage(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel)

    func displayRouteToMailStartScreen(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel)
    func displayRouteToSaveDialog(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel)
    func displayRouteToOpenData(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel)

    func displayRouteToNewEmailCreate(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel)
}


// MARK: - OneFilmDetailsController

final class OneFilmDetailsController: UIViewController, NavigationBarControllable, AlertDisplayable {

    var interactor: OneFilmDetailsBusinessLogic?
    var router: (OneFilmDetailsRoutingLogic & OneFilmDetailsDataPassing)?

    lazy var contentView: OneFilmDetailsViewLogic = OneFilmDetailsView()
    
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
        interactor?.onDidLoadViews(request: OneFilmDetailsFlow.OnDidLoadViews.Request())
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
            interactor?.markAsUnread(request: OneFilmDetailsFlow.OnEnvelopNavBarButton.Request())
        case 2:
            interactor?.didTapTrashNavBarIcon(request: OneFilmDetailsFlow.OnTrashNavBarIcon.Request())
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

// MARK: - OneFilmDetailsDisplayLogic

extension OneFilmDetailsController: OneFilmDetailsDisplayLogic {

    func displayRouteToOpenData(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToOpenData()
    }

    func displayRouteToMailStartScreen(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToMailStartScreen()
    }

    func displayRouteToSaveDialog(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToSaveDialog()
    }

    ///If photo - task router to show it
    func displayRouteToOpenImage(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToOpenImage()
    }

    func displayRouteToNewEmailCreate(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel) {
        router?.routeToNewEmailCreate()
    }

    func displayUpdate(viewModel: OneFilmDetailsFlow.Update.ViewModel) {
        if didNavBarSet == false {
            configureNavigationBar(navBar: viewModel.navBar)
            showNavigationBar(animated: false)
            didNavBarSet = true
        }
        setNeedsStatusBarAppearanceUpdate()
        contentView.update(viewModel: viewModel)
    }

    func displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel) {
        contentView.displayWaitIndicator(viewModel: viewModel)
    }

    func displayAlert(viewModel: OneFilmDetailsFlow.AlertInfo.ViewModel) {
        showAlert(title: viewModel.title,
                  message: viewModel.text,
                  firstButtonTitle: viewModel.buttonTitle ?? "Ok")
    }
}

// MARK: - OneFilmDetailsViewOutput

extension OneFilmDetailsController: OneFilmDetailsViewOutput {
//    func didTapAtXButtonAtCloudAttachment(_ viewModel: CloudEmailAttachmentViewModel) { }
//
//
//    func chevronOpenCloseAddressesTapped() {
//        interactor?.didTapChevronAdresses(request: OneFilmDetailsFlow.OnChevronTapped.Request())
//    }
//
//    // MARK: CloudEmailAttachmentOutput
//    func didTapAtCloudAttachment(_ viewModel: CloudEmailAttachmentViewModel){
//        interactor?.didTapAtFileOrFoto(request: OneFilmDetailsFlow.OnAttachedFileOrImageTapped.Request(cloudEmailViewModel: viewModel))
//    }
//
//    // MARK: FotoOutput
//    func didTapAtFoto(_ viewModel: FotoCellViewModel) {
//        interactor?.didTapAtFileOrFoto(request: OneFilmDetailsFlow.OnAttachedFileOrImageTapped.Request(fotoViewModel: viewModel))
//    }
//
//    func didTapAtDownloadIcon(_ viewModel: FotoCellViewModel) {
//        interactor?.didTapDownloadIcon(request: OneFilmDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Request(fotoViewModel: viewModel))
//    }
//
//    func didTapAtQuattroIcon(_ viewModel: FotoCellViewModel) {
//        interactor?.didTapQuattroIcon(request: OneFilmDetailsFlow.OnQuattroIcon.Request())
//    }
//
//    // MARK: ButtonsOutput
//    func didTapReply(viewModel: OneEmailDetailsButtonsViewModel.ButtonType) {
//        interactor?.didTapReplyButton(request: OneFilmDetailsFlow.OnReplyButton.Request())
//    }
//
//    func didTapReplyToAll(viewModel: OneEmailDetailsButtonsViewModel.ButtonType) {
//        interactor?.didTapReplyToAllButton(request: OneFilmDetailsFlow.OnReplyToAllButton.Request())
//    }
//
//    func didTapForward(viewModel: OneEmailDetailsButtonsViewModel.ButtonType) {
//        interactor?.didTapForwardButton(request: OneFilmDetailsFlow.OnForwardButton.Request())
//    }
}


