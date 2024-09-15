//
//  FilmsInteractor.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import UIKit

protocol FilmsBusinessLogic {
    func onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request)
    func didTapLogOff(request: FilmsScreenFlow.OnLogOffBarItemTap.Request)

    func didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request)
    func didTapSearchBarIcon(request: FilmsScreenFlow.OnSearchBarGlassIconTap.Request)

    func filterByYear(request: FilmsScreenFlow.OnYearButtonTap.Request)
    func onCellTap(request: FilmsScreenFlow.OnSelectItem.Request)
}

protocol FilmsDataStore: AnyObject {
    var oneFilmForOpenDetails: ContactListItem { get }
}

final class FilmsInteractor: FilmsBusinessLogic, FilmsDataStore {

    // MARK: - Public properties

    var presenter: FilmsPresentationLogic?
    var worker: FilmsWorkingLogic?

    var allFilms: Set<ContactListItem> = []
    var oneFilmForOpenDetails = ContactListItem()
//    var typeOfSearch: TypeOfSearch
    

    // MARK: - Private properties
    private var isSearchingAtSearchField = false
    private var emailsToShow: [String] {
        get {
            if isSearchingAtSearchField == true {
                return filteredFilms
            } else {
                return allEmailsArray
            }
        }
    }

    private var allEmailsArray: [String] = []
    private var filteredFilms: [String] = []
    private var allEmailsSet: Set<String> = []

    // MARK: - Public methods

    func onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request) {
        presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: true))
        worker?.getFilms(){ [weak self] result in
            guard let self = self else { return }
            presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: false))

            switch result {
            case .success(let films):
                Log.i("Contacts got successfully")
                allEmailsArray = contacts.map { $0.email.lowercased() }
                allEmailsSet = Set(allEmailsArray)

                allContactsSet = Set(contacts.map { ContactListItem(withEmailLowercased: $0) })

                if typeOfSearch == .server { //if came from sideMenu
                    isSearchBarDisplaying = true
                    presenter?.presentSearchBar(response: FilmsScreenFlow.OnSearchBarGlassIconTap.Response(
                        searchText: nil,
                        isSearchBarDisplaying: isSearchBarDisplaying))
                }
                presenterDoUpdate()

            case .failure(let failure):
                Log.e(failure.localizedDescription)
                presenter?.presentAlert(response: FilmsScreenFlow.AlertInfo.Response(error: failure))
            }
        }
    }

    func didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request) {
//        <#code#>
    }


    func filterByYear(request: FilmsScreenFlow.OnYearButtonTap.Request) {
//        <#code#>
    }

    func didTapSearchBarIcon(request: FilmsScreenFlow.OnSearchBarGlassIconTap.Request) {
        guard let searchingText = request.searchText else { return }

//        if !searchingText.isEmpty {
//            presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: true))
//
//            worker?.searchContacts(by: searchingText) { [weak self] result in
//                guard let self = self else { return }
//                presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: false))
//
//                switch result {
//                case .success(let filteredEmails):
//                    Log.i("Contacts found successfully")
//                    self.filteredEmails = filteredEmails
//                    isSearchingAtSearchField = true
//                    isMultiPickingMode = doesAllEmailsContainPickedEmails
//
//                    presenterDoUpdate()
//
//                case .failure(let failure):
//                    Log.e(failure.localizedDescription)
//                    presenter?.presentAlert(response: FilmsScreenFlow.AlertInfo.Response(error: failure))
//                }
//            }
//        } else if searchingText == "" {
//            isSearchingAtSearchField = false
//            presenterDoUpdate()
//        }
    }

    func onCellTap(request: FilmsScreenFlow.OnSelectItem.Request) {
//        if let oneFilmDetails = allContactsSet.first(where: { $0.uid == request.id }) {
//            oneContactInfoForOpenDetails = oneContactDetails
//            presenter?.presentRouteToOneFilmDetails(response: FilmsScreenFlow.RoutePayload.Response())
//        }
    }

    func didTapLogOff(request: FilmsScreenFlow.OnLogOffBarItemTap.Request) {
        presenter?.presentRouteBackToLoginScreen(response: FilmsScreenFlow.OnSelectItem.Response())
    }

    //MARK: - Private methods

    private func presenterDoUpdate() {
//        presenter?.presentUpdate(response: FilmsScreenFlow.Update.Response(
//            pickedEmailAddresses: pickedEmailAddresses,
//            isCheckmarkBarIconActive: isCheckmarkBarIconActive,
//            emailsToShow: emailsToShow,
//            allContactsSet: allContactsSet,
//            isMultiPickingMode: isMultiPickingMode,
//            doesAllEmailsContainPickedEmails: doesAllEmailsContainPickedEmails,
//            typeOfSearch: typeOfSearch))
    }
}
