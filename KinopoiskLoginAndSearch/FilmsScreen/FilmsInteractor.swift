//
//  AddressBookInteractor.swift
//  SGTS
//
//  Created by Roman Vakulenko on 20.05.2024.
//

import Foundation
import UIKit

protocol AddressBookBusinessLogic {
    func onDidLoadViews(request: AddressBookFlow.OnDidLoadViews.Request)
    func onAvatarTap(request: AddressBookFlow.OnAvatarTap.Request)
    func onCellTap(request: AddressBookFlow.OnSelectItem.Request)

    func didLongPressAtContactCell(request: AddressBookFlow.OnSelectItem.Request)
    func didTapSandwichOrBackButton(request: AddressBookFlow.RoutePayload.Request)
    func didTapSearchNavBarIcon(request: AddressBookFlow.OnSearchNavBarIconTap.Request)
    func didTapSearchIconInSearchBar(request: AddressBookFlow.OnSearchNavBarIconTap.Request)
    func selectOrRouteToNewEmailAfterPickingFromOneContactDetails(isMultiPickingMode: Bool, pickedEmailAddress: String)

    func didTapCheckmarkOrPlaneBarButton(request: AddressBookFlow.OnCheckmarkBarIconTap.Request)
    func clearSelectionIfOnlyOneWasPickedBeforeNewEmail()
}

protocol AddressBookDataStore: AnyObject {
    var pickedEmailAddresses: [String] { get }
    var oneContactInfoForOpenDetails: ContactListItem { get }
    var allContactsSet: Set<ContactListItem> { get }
    var isMultiPickingMode: Bool { get }
    var typeOfSearch: TypeOfSearch { get }
}

final class AddressBookInteractor: AddressBookBusinessLogic, AddressBookDataStore {

    // MARK: - Public properties

    var presenter: AddressBookPresentationLogic?
    var worker: AddressBookWorkingLogic?

    var pickedEmailAddresses: [String] {
        didSet { pickedEmailAddresses = pickedEmailAddresses.map {$0.lowercased()} }
    }
    var allContactsSet: Set<ContactListItem> = []
    var oneContactInfoForOpenDetails = ContactListItem()
    var isMultiPickingMode = false
    var typeOfSearch: TypeOfSearch
    

    // MARK: - Private properties

    private var isCheckmarkBarIconActive: Bool {
        get {
            if isMultiPickingMode == true && emailAddressesAlreadyEnteredInField != pickedEmailAddresses { // мультиМод и изменились
                return true
            } else {
                return false
            }
        }
    }
    private var isSearchingAtSearchField = false
    private var emailsToShow: [String] {
        get {
            if isSearchingAtSearchField == true {
                return filteredEmails
            } else {
                return allEmailsArray
            }
        }
    }

    private var allEmailsArray: [String] = []
    private var filteredEmails: [String] = []
    private var allEmailsSet: Set<String> = []
    private var emailAddressesAlreadyEnteredInField: [String] = []
    private var isSearchBarDisplaying = false
    private var doesAllEmailsContainPickedEmails = false

    // MARK: - Init
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(emailAddresses: [String], searchFrom: TypeOfSearch) {
        self.pickedEmailAddresses = emailAddresses
        self.typeOfSearch = searchFrom
        self.emailAddressesAlreadyEnteredInField = emailAddresses
    }

    // MARK: - Public methods

    func onDidLoadViews(request: AddressBookFlow.OnDidLoadViews.Request) {
        observeThemeChanging()
        observeLangChanging()
        presenter?.presentWaitIndicator(response: AddressBookFlow.OnWaitIndicator.Response(isShow: true))

        worker?.getAllContacts(){ [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let contacts):
                Log.i("Contacts got successfully")
                allEmailsArray = contacts.map { $0.email.lowercased() }
                allEmailsSet = Set(allEmailsArray)

                allContactsSet = Set(contacts.map { ContactListItem(withEmailLowercased: $0) })

                // Если хотя бы один контакт найден среди всех контактов - true, иначе false
                doesAllEmailsContainPickedEmails = pickedEmailAddresses.contains { pickedEmail in
                    self.allEmailsSet.contains(pickedEmail)
                }

                isMultiPickingMode = doesAllEmailsContainPickedEmails

                if typeOfSearch == .server { //if came from sideMenu
                    isSearchBarDisplaying = true
                    presenter?.presentSearchBar(response: AddressBookFlow.OnSearchNavBarIconTap.Response(
                        searchText: nil,
                        isSearchBarDisplaying: isSearchBarDisplaying))
                }
                presenterDoUpdate()

            case .failure(let failure):
                Log.e(failure.localizedDescription)
                presenter?.presentAlert(response: AddressBookFlow.AlertInfo.Response(error: failure))
            }
        }
    }

    func clearSelectionIfOnlyOneWasPickedBeforeNewEmail() {
        if doesAllEmailsContainPickedEmails && pickedEmailAddresses.count == 1 && typeOfSearch == .server {
            pickedEmailAddresses = []
        }
    }

    func onAvatarTap(request: AddressBookFlow.OnAvatarTap.Request) {
        Log.i("onAvatarTap")
        removeOrAddPicked(email: request.onePickedEmailAddress)
        doesAllEmailsContainPickedEmails = true

        if isMultiPickingMode == false && pickedEmailAddresses.count > 0 {
            presenter?.presentRouteToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response(somePickedEmailAddresses: pickedEmailAddresses))
        }

        if isMultiPickingMode == true {
            presenterDoUpdate()
        }

    }

    func onCellTap(request: AddressBookFlow.OnSelectItem.Request) {
        Log.i("onCellTap")
        if let oneContactDetails = allContactsSet.first(where: { $0.uid == request.id }) {
            oneContactInfoForOpenDetails = oneContactDetails
            presenter?.presentRouteToOneContactDetails(response: AddressBookFlow.RoutePayload.Response())
        }
    }

    func didLongPressAtContactCell(request: AddressBookFlow.OnSelectItem.Request) {
        Log.i("didLongPressAtContactCell")
        isMultiPickingMode = true
        removeOrAddPicked(email: request.onePickedEmailAddress)
        doesAllEmailsContainPickedEmails = true

        presenterDoUpdate()
    }


    func selectOrRouteToNewEmailAfterPickingFromOneContactDetails(isMultiPickingMode: Bool,
                                                                  pickedEmailAddress: String) {
        if isMultiPickingMode == false {
            pickedEmailAddresses.append(pickedEmailAddress)
            presenter?.presentRouteToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response(somePickedEmailAddresses: pickedEmailAddresses))
        }

        if isMultiPickingMode == true {
            removeOrAddPicked(email: pickedEmailAddress)
            doesAllEmailsContainPickedEmails = true

            presenterDoUpdate()
        }
    }

    func didTapSandwichOrBackButton(request: AddressBookFlow.RoutePayload.Request) {
        Log.i("Tapped side menu button")
        switch typeOfSearch {
        case .database: // Back
            presenter?.presentRouteBackToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response(somePickedEmailAddresses: pickedEmailAddresses))
        case .server: // Sandwich
            presenter?.presentRouteToSideMenu(response: AddressBookFlow.RoutePayload.Response())
        }
    }

    func didTapSearchNavBarIcon(request: AddressBookFlow.OnSearchNavBarIconTap.Request) {
        Log.i("didTapSearchBarIcon")
        isSearchBarDisplaying = request.isSearchBarDisplaying
        presenter?.presentSearchBar(response: AddressBookFlow.OnSearchNavBarIconTap.Response(
            searchText: nil,
            isSearchBarDisplaying: isSearchBarDisplaying))

        isSearchingAtSearchField = false
        presenterDoUpdate()
    }


    func didTapSearchIconInSearchBar(request: AddressBookFlow.OnSearchNavBarIconTap.Request) {
        guard let searchingText = request.searchText else { return }

        if !searchingText.isEmpty {
            presenter?.presentWaitIndicator(response: AddressBookFlow.OnWaitIndicator.Response(isShow: true))

            worker?.searchContacts(by: searchingText) { [weak self] result in
                guard let self = self else { return }
                presenter?.presentWaitIndicator(response: AddressBookFlow.OnWaitIndicator.Response(isShow: false))

                switch result {
                case .success(let filteredEmails):
                    Log.i("Contacts found successfully")
                    self.filteredEmails = filteredEmails
                    isSearchingAtSearchField = true
                    isMultiPickingMode = doesAllEmailsContainPickedEmails

                    presenterDoUpdate()

                case .failure(let failure):
                    Log.e(failure.localizedDescription)
                    presenter?.presentAlert(response: AddressBookFlow.AlertInfo.Response(error: failure))
                }
            }
        } else if searchingText == "" {
            isSearchingAtSearchField = false
            presenterDoUpdate()
        }
    }


    func didTapCheckmarkOrPlaneBarButton(request: AddressBookFlow.OnCheckmarkBarIconTap.Request) {
        if isCheckmarkBarIconActive == true || typeOfSearch == .server {
            presenter?.presentRouteToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response(somePickedEmailAddresses: pickedEmailAddresses))
        }
    }

    //MARK: - Private methods

    private func presenterDoUpdate() {
        presenter?.presentUpdate(response: AddressBookFlow.Update.Response(
            pickedEmailAddresses: pickedEmailAddresses,
            isCheckmarkBarIconActive: isCheckmarkBarIconActive,
            emailsToShow: emailsToShow,
            allContactsSet: allContactsSet,
            isMultiPickingMode: isMultiPickingMode,
            doesAllEmailsContainPickedEmails: doesAllEmailsContainPickedEmails,
            typeOfSearch: typeOfSearch))
    }

    private func removeOrAddPicked(email: String) {
        if pickedEmailAddresses.contains(email) {
            pickedEmailAddresses.removeAll { $0 == email } //delete at repeated tap or if was entered and repeated tap will delete
        } else {
            pickedEmailAddresses.append(email)
        }
    }

    ///Light or Dark theme
    private func observeThemeChanging() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.screenThemeWasChanged,
            object: nil, queue: nil) { [weak self] _ in
                guard let self else {return}
                self.presenterDoUpdate()
            }
    }

    private func observeLangChanging() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.languageWasChangedNotification,
            object: nil, queue: nil) { [weak self] _ in
                guard let self else {return}
                self.presenterDoUpdate()
            }
    }
}
