//
//  OneFilmDetailsController.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol OneFilmDetailsDisplayLogic: AnyObject {
    func displayUpdateAllButStills(viewModel: OneFilmDetailsFlow.UpdateAllButStills.ViewModel)
    func displayUpdateStills(viewModel: OneFilmDetailsFlow.UpdateStills.ViewModel)

    func displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel)
    func displayAlert(viewModel: OneFilmDetailsFlow.AlertInfo.ViewModel)
//    func displayRouteToOpenImage(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel)
    func displayRouteToWeb(viewModel: OneFilmDetailsFlow.OnWebLinkTap.ViewModel)
}


// MARK: - OneFilmDetailsController

final class OneFilmDetailsController: UIViewController, AlertDisplayable {

    var interactor: OneFilmDetailsBusinessLogic?
    var router: (OneFilmDetailsRoutingLogic & OneFilmDetailsDataPassing)?

    lazy var contentView: OneFilmDetailsViewLogic = OneFilmDetailsView()
    
    // MARK: - Private methods

    private var didNavBarSet = false

    // MARK: - Lifecycle
    
    override func loadView() {
        contentView.output = self
        view = contentView
//        hideNavigationBar(animated: false) //to hide flashing blue "< Back"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        interactor?.onDidLoadViews(request: OneFilmDetailsFlow.OnDidLoadViews.Request())
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

//    func displayRouteToOpenImage(viewModel: OneFilmDetailsFlow.RoutePayload.ViewModel) {
//        router?.routeToOpenImage()
//    }


    func displayRouteToWeb(viewModel: OneFilmDetailsFlow.OnWebLinkTap.ViewModel) {
        router?.routeToWeb()
    }

    func displayUpdateAllButStills(viewModel: OneFilmDetailsFlow.UpdateAllButStills.ViewModel) {
        contentView.updateAllButStills(viewModel: viewModel)
    }

    func displayUpdateStills(viewModel: OneFilmDetailsFlow.UpdateStills.ViewModel) {
        contentView.updateStills(viewModel: viewModel)
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
    func didTapChevronBack() {
        router?.routeBackToFilmsScreen()
    }
    
    func loadNextTwentyStills() {
        interactor?.loadNextTwentyStills(request: OneFilmDetailsFlow.OnLoadRequest.Request())
    }
    
    func didTapAtOneStill(_ viewModel: StillCollectionCellViewModel) {
        () // задании не было - потенциально можно было бы считать и настроить, напримре, показ на полный экран того кадра (но в ТЗ не было)
    }

    func didTapWebLink() {
        interactor?.didTapWebLink(request: OneFilmDetailsFlow.OnWebLinkTap.Request())
    }
}


