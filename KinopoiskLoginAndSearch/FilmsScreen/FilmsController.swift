//
//  AddressBookController.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import UIKit
import SnapKit

protocol AddressBookDisplayLogic: AnyObject {
    func toggleSearchBar(viewModel: AddressBookFlow.OnSearchNavBarIconTap.ViewModel)

    func displayUpdate(viewModel: AddressBookFlow.Update.ViewModel)
    func displayWaitIndicator(viewModel: AddressBookFlow.OnWaitIndicator.ViewModel)
    func displayAlert(viewModel: AddressBookFlow.AlertInfo.ViewModel)

    func displayRouteToSideMenu(viewModel: AddressBookFlow.RoutePayload.ViewModel)
    func displayRouteBackToNewEmailCreateScreen(viewModel: AddressBookFlow.RoutePayload.ViewModel)
    func displayRouteToNewEmailCreateScreen(viewModel: AddressBookFlow.RoutePayload.ViewModel)
    func displayRouteToOneContactDetails(viewModel: AddressBookFlow.RoutePayload.ViewModel)
}

final class AddressBookController: UIViewController, FileShareable, AlertDisplayable, NavigationBarControllable {

    var interactor: AddressBookBusinessLogic?
    var router: (AddressBookRoutingLogic & AddressBookDataPassing)?
    lazy var contentView: AddressBookViewLogic = AddressBookView()

    weak var delegate: AddressBookGetAdressesDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.shared.isLight ? .darkContent : .lightContent
    }

    // MARK: - Private properties

    private var isSearchBarDisplaying = false
    private var didTabBarSet = false
    private var searchFrom: TypeOfSearch

    // MARK: - Lifecycle

    init(delegate: AddressBookGetAdressesDelegate?, searchFrom: TypeOfSearch) {
        self.searchFrom = searchFrom
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        contentView.output = self
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        hideNavigationBar(animated: false)
        interactor?.onDidLoadViews(request: AddressBookFlow.OnDidLoadViews.Request())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.clearSelectionIfOnlyOneWasPickedBeforeNewEmail()
    }

    func leftNavBarButtonDidTapped() {
        interactor?.didTapSandwichOrBackButton(request: AddressBookFlow.RoutePayload.Request())
    }

    func rightNavBarButtonTapped(index: Int) {
        switch index {
        case 0: //checkmarkNavBarIcon or planeButton(creating newEmail)
            interactor?.didTapCheckmarkOrPlaneBarButton(request: AddressBookFlow.OnCheckmarkBarIconTap.Request())
        case 1: //searchNavBarIcon
            isSearchBarDisplaying.toggle()
            interactor?.didTapSearchNavBarIcon(request: AddressBookFlow.OnSearchNavBarIconTap.Request(
                searchText: nil,
                isSearchBarDisplaying: isSearchBarDisplaying))
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

extension AddressBookController: AddressBookDisplayLogic {
    func toggleSearchBar(viewModel: AddressBookFlow.OnSearchNavBarIconTap.ViewModel) {
        contentView.toggleSearchBar(viewModel: viewModel)
    }

    func displayUpdate(viewModel: AddressBookFlow.Update.ViewModel) {
        configureNavigationBar(navBar: viewModel.navBar)
        showNavigationBar(animated: false)
        if !didTabBarSet,
           let navController = self.navigationController,
           searchFrom == .server {
            TabBarManager.configureTabBarItem(for: navController,
                                              title: viewModel.tabBarTitle ?? "",
                                              image: viewModel.tabBarImage ?? UIImage(),
                                              selectedImage: viewModel.tabBarSelectedImage ?? UIImage())
            didTabBarSet = true
        }
        setNeedsStatusBarAppearanceUpdate()
        contentView.update(viewModel: viewModel)
    }

    func displayRouteToOneContactDetails(viewModel: AddressBookFlow.RoutePayload.ViewModel) {
        router?.routeToOneContactDetails()
    }

    func displayRouteToSideMenu(viewModel: AddressBookFlow.RoutePayload.ViewModel) {
        router?.routeToSideMenu()
    }

    func displayRouteBackToNewEmailCreateScreen(viewModel: AddressBookFlow.RoutePayload.ViewModel) {
        router?.routeBackToNewEmailCreateScreen()
    }

    func displayRouteToNewEmailCreateScreen(viewModel: AddressBookFlow.RoutePayload.ViewModel) {
        router?.routeToNewEmailCreateScreen()
    }

    func displayWaitIndicator(viewModel: AddressBookFlow.OnWaitIndicator.ViewModel) {
        contentView.displayWaitIndicator(viewModel: viewModel)
    }

    func displayAlert(viewModel: AddressBookFlow.AlertInfo.ViewModel) {
        showAlert(title: viewModel.title,
                  message: viewModel.text,
                  firstButtonTitle: viewModel.buttonTitle ?? "Ok")
    }
}

// MARK: - AddressBookViewOutput

extension AddressBookController: AddressBookViewOutput {

    func didTapAtSearchIconInSearchView(searchText: String) {
        interactor?.didTapSearchIconInSearchBar(request: AddressBookFlow.OnSearchNavBarIconTap.Request(
            searchText: searchText,
            isSearchBarDisplaying: isSearchBarDisplaying))
    }

    func didLongPressAt(_ viewModel: ContactNameAndAddressCellViewModel) {
        interactor?.didLongPressAtContactCell(request: AddressBookFlow.OnSelectItem.Request(
            id: viewModel.id,
            onePickedEmailAddress: viewModel.email.string))
    }

    func didTapAtAvatar(_ viewModel: ContactNameAndAddressCellViewModel) {
        interactor?.onAvatarTap(request: AddressBookFlow.OnAvatarTap.Request(
            onePickedEmailAddress: viewModel.email.string))
    }

    func didTapAtOneEmail(_ viewModel: ContactNameAndAddressCellViewModel) {
        interactor?.onCellTap(request: AddressBookFlow.OnSelectItem.Request(
            id: viewModel.id,
            onePickedEmailAddress: viewModel.email.string))
    }
}


// MARK: - OneContactDetailsDelegate
extension AddressBookController: OneContactDetailsDelegate {
    func useEmailFromOneContactDetails(pickedEmailAddress: String, isMultiPickingMode: Bool) {
        interactor?.selectOrRouteToNewEmailAfterPickingFromOneContactDetails(isMultiPickingMode: isMultiPickingMode,
                                                                             pickedEmailAddress: pickedEmailAddress)
    }
}

