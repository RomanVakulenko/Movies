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
    var router: (FilmsRoutingLogic & FilmsDataPassing & DatePickerRouterProtocol)?
    lazy var contentView: FilmsViewLogic = FilmsView()
    
    weak var delegate: FilmsDelegate?

    // MARK: - Private properties

    private var didNavBarSet = false

    // MARK: - Lifecycle

    init(delegate: FilmsDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        contentView.output = self
        view = contentView
        hideNavigationBar(animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        interactor?.onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request())
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
    func didPullToReftesh() {
        interactor?.updateFilmsAtRefresh(request: FilmsScreenFlow.Update.Request())
    }
 
    func loadNextFilmsIfAvaliable() {
        interactor?.loadNextFilms(request: FilmsScreenFlow.OnLoadRequest.Request(isRefreshRequested: false))
    }

    func doSearchFor(searchText: String) {
        interactor?.doSearchFor(request: FilmsScreenFlow.OnSearchBarGlassIconTap.Request(searchText: searchText))
    }

    func didTapSortIcon() {
        interactor?.didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request())
    }

    func yearButtonTapped() {
        router?.presentYearPicker(from: self) { [weak self] selectedYear in
            self?.interactor?.filterByYear(request: FilmsScreenFlow.OnYearButtonTap.Request(year: selectedYear))
        }
    }

    func didTapAOneFilm(_ viewModel: FilmsTableCellViewModel) {
        interactor?.onCellTap(request: FilmsScreenFlow.OnSelectItem.Request(id: viewModel.filmId))
    }

    
}

extension FilmsController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GlobalConstants.currentYear - GlobalConstants.defaultSelectedYear + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(GlobalConstants.defaultSelectedYear + row)"
    }
}
