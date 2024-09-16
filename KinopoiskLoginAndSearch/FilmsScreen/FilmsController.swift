//
//  FilmsController.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol FilmsDisplayLogic: AnyObject {
    func displayUpdate(viewModel: FilmsScreenFlow.Update.ViewModel)
    func displaySearchView(viewModel: FilmsScreenFlow.UpdateSearch.ViewModel)

    func displayWaitIndicator(viewModel: FilmsScreenFlow.OnWaitIndicator.ViewModel)
    func displayAlert(viewModel: FilmsScreenFlow.AlertInfo.ViewModel)

    func displayRouteToOneFilmDetails(viewModel: FilmsScreenFlow.RoutePayload.ViewModel)
    func displayRouteBackToLoginScreen(viewModel: FilmsScreenFlow.RoutePayload.ViewModel)
}

final class FilmsController: UIViewController, AlertDisplayable, NavigationBarControllable {

    var interactor: FilmsBusinessLogic?
    var router: (FilmsRoutingLogic & FilmsDataPassing)?
    lazy var contentView: FilmsViewLogic = FilmsView()

    // MARK: - Private properties

    private var didNavBarSet = false

    // MARK: - Lifecycle

    override func loadView() {
        contentView.output = self
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        interactor?.onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        interactor?.clearSelectionIfOnlyOneWasPickedBeforeNewEmail()
    }

    func leftNavBarButtonDidTapped() {
        ()
    }

    func rightNavBarButtonTapped(index: Int) {
        switch index {
        case 0:
            interactor?.didTapLogOff(request: FilmsScreenFlow.OnLogOffBarItemTap.Request())
        default:
            break
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

// MARK: - AddressBookDisplayLogic

extension FilmsController: FilmsDisplayLogic {

    func displaySearchView(viewModel: FilmsScreenFlow.UpdateSearch.ViewModel) {
        contentView.updateSearchView(viewModel: viewModel)
    }


    func displayUpdate(viewModel: FilmsScreenFlow.Update.ViewModel) {
        if didNavBarSet == false {
            configureNavigationBar(navBar: viewModel.navBar)
            showNavigationBar(animated: false)
            didNavBarSet = true
        }
        contentView.update(viewModel: viewModel)
    }

    func displayRouteToOneFilmDetails(viewModel: FilmsScreenFlow.RoutePayload.ViewModel) {
        router?.routeToOneFilmDetails()
    }

    func displayRouteBackToLoginScreen(viewModel: FilmsScreenFlow.RoutePayload.ViewModel) {
        router?.routeBackToLoginScreen()
    }

    func displayWaitIndicator(viewModel: FilmsScreenFlow.OnWaitIndicator.ViewModel) {
        contentView.displayWaitIndicator(viewModel: viewModel)
    }

    func displayAlert(viewModel: FilmsScreenFlow.AlertInfo.ViewModel) {
        showAlert(title: viewModel.title,
                  message: viewModel.text,
                  firstButtonTitle: viewModel.buttonTitle ?? "Ok")
    }
}

// MARK: - AddressBookViewOutput

extension FilmsController: FilmsViewOutput {
    func loadNextTwentyFilms() {
        interactor?.loadNextTwentyFilms(request: FilmsScreenFlow.OnLoadRequest.Request())
    }

    func didTapAtSearchIconInSearchView(searchText: String) {
        interactor?.didTapSearchBarIcon(request: FilmsScreenFlow.OnSearchBarGlassIconTap.Request(searchText: searchText))
    }
    

    func didTapSortIcon() {
        interactor?.didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request(
            isSorredByIncreasing: <#Bool#>))
    }

    func yearButtonTapped() {
//        <#code#>
    }

    func didTapAOneFilm(_ viewModel: FilmsTableCellViewModel) {
        interactor?.onCellTap(request: FilmsScreenFlow.OnSelectItem.Request(id: viewModel.filmId))
    }

    
}
