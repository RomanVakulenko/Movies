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
    func loadNextTwentyFilms(request: FilmsScreenFlow.OnLoadRequest.Request)
}

protocol FilmsDataStore: AnyObject {
    var idOfSelectedFilm: Int? { get }
}

final class FilmsInteractor: FilmsBusinessLogic, FilmsDataStore {

    // MARK: - Public properties

    var presenter: FilmsPresentationLogic?
    var worker: FilmsWorkingLogic?
    var idOfSelectedFilm: Int?

    // MARK: - Private properties
    private var isSearchingAtSearchField = false

    private var filmsSortedFiltered: [OneFilm] = []
    private var isSortedDescending = true
    private var isFilteredByYear = false
    private var yearForFilter = 0

    // MARK: - Public methods

    func onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request) {
        presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: true))
        
        worker?.loadFilms{ [weak self] result in
            guard let self = self else { return }
            presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: false))

            switch result {
            case .success(let films):
                filmsSortedFiltered = films.sorted { $0.ratingKinopoisk ?? 0.1 > $1.ratingKinopoisk ?? 0.0 }
                presenterDoUpdate()

            case .failure(let failure):
                presenter?.presentAlert(response: FilmsScreenFlow.AlertInfo.Response(error: failure))
            }
        }
    }

    func loadNextTwentyFilms(request: FilmsScreenFlow.OnLoadRequest.Request) {

    }

    func didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request) {
        isSortedDescending.toggle()
        sortOrFilterFilms()
    }

    func filterByYear(request: FilmsScreenFlow.OnYearButtonTap.Request) {
        yearForFilter = request.year
        isFilteredByYear = true
        sortOrFilterFilms()
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
        idOfSelectedFilm
//        if let oneFilmDetails = allContactsSet.first(where: { $0.uid == request.id }) {
//            oneContactInfoForOpenDetails = oneContactDetails
//            presenter?.presentRouteToOneFilmDetails(response: FilmsScreenFlow.RoutePayload.Response())
//        }
    }

    func didTapLogOff(request: FilmsScreenFlow.OnLogOffBarItemTap.Request) {
        presenter?.presentRouteBackToLoginScreen(response: FilmsScreenFlow.OnSelectItem.Response())
    }

    //MARK: - Private methods

    private func sortOrFilterFilms() {
        let sortedAndFiltered: [OneFilm]

        if isFilteredByYear {
            sortedAndFiltered = filmsSortedFiltered.filter { film in
                film.year == yearForFilter
            }
        } else {
            sortedAndFiltered = filmsSortedFiltered
        }

        sortedAndFiltered.sort { film1, film2 in
            let rating1 = film1.ratingKinopoisk ?? 0.0
            let rating2 = film2.ratingKinopoisk ?? 0.0

            if rating1 == rating2 {
                return film1.nameOriginal < film2.nameOriginal
            }
            return isSortedDescending ? rating1 > rating2 : rating1 < rating2
        }
        presenterDoUpdate()
    }


    private func presenterDoUpdate() {
        presenter?.presentUpdate(response: FilmsScreenFlow.Update.Response(filmsSortedFiltered: filmsSortedFiltered))
    }
}
