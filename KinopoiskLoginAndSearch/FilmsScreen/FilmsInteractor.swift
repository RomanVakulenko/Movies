//
//  FilmsInteractor.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import UIKit

protocol FilmsBusinessLogic {
    func didTapLogOff(request: FilmsScreenFlow.OnLogOffBarItemTap.Request)
    func onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request)
    func updateFilmsAtRefresh(request: FilmsScreenFlow.Update.Request)

    func didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request)
    func doSearchFor(request: FilmsScreenFlow.OnSearchBarGlassIconTap.Request)

    func filterByYear(request: FilmsScreenFlow.OnYearButtonTap.Request)
    func onCellTap(request: FilmsScreenFlow.OnSelectItem.Request)
    func loadNextFilms(request: FilmsScreenFlow.OnLoadRequest.Request)

}

protocol FilmsDataStore: AnyObject {
    var idOfSelectedFilm: Int? { get }
    var yearForFilter: Int { get set }
}

final class FilmsInteractor: FilmsBusinessLogic, FilmsDataStore {

    // MARK: - Public properties
    enum Constants {
        static let defaultYear = 1900
    }

    var presenter: FilmsPresentationLogic?
    var worker: FilmsWorkingLogic?
    var idOfSelectedFilm: Int?
    var yearForFilter = Constants.defaultYear

    // MARK: - Private properties

    private var filmsToDisplay: [OneFilm] = []
    private var filteredFilms: [OneFilm] = []
    private var allFetchedFilms: [OneFilm] = []
    private var filmsAvailiableToFetch = 0

    private var isSortedDescending = true //по убыванию
    private var isFilteredByYear = false
    private var isSearching = false
    private var isAtSearchingOrFilteredYearOrSortedAscending: Bool {
        if isSortedDescending && !isFilteredByYear && !isSearching {
            return false
        } else {
            return true
        }
    }
    private var isAllFilmsFetched: Bool {
        if allFetchedFilms.count == filmsAvailiableToFetch {
            return true
        } else {
            return false
        }
    }

    // MARK: - Public methods

    func onDidLoadViews(request: FilmsScreenFlow.OnDidLoadViews.Request) {
        presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: true))

        workerLoadFilms(isRefreshRequested: false) { filmsToDisplay in
            self.presenter?.presentSearchBar(response: FilmsScreenFlow.UpdateSearch.Response())
            self.presenterDoUpdate()
            self.presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: false))

            self.loadAvatarsFor(films: filmsToDisplay) { _ in
                self.presenterDoUpdate()
            }
        }
    }

    func loadNextFilms(request: FilmsScreenFlow.OnLoadRequest.Request) {
        if isAllFilmsFetched == false {
            workerLoadFilms(isRefreshRequested: false) { films in
                self.loadAvatarsFor(films: films) { _ in
                    self.presenterDoUpdate()
                }
            }
        } else {
            //можно вывести уведомление, что все фильмы скачаны
        }
    }
    
    func updateFilmsAtRefresh(request: FilmsScreenFlow.Update.Request) {
        allFetchedFilms = []
        isSortedDescending = true
        isFilteredByYear = false
        isSearching = false
        yearForFilter = Constants.defaultYear

        if isAllFilmsFetched == false {
            workerLoadFilms(isRefreshRequested: true) { films in
                self.loadAvatarsFor(films: films) { _ in
                    self.presenterDoUpdate()
                }
            }
        } else {
            //можно вывести уведомление, что все фильмы скачаны
        }
    }

    func didTapSortIcon(request: FilmsScreenFlow.OnSortIconTap.Request) {
        isSortedDescending.toggle()

        sortOrFilterFilmsByYear() { sortedAndFiltered in
            self.filmsToDisplay = sortedAndFiltered
            self.presenterDoUpdate()
        }
    }

    func filterByYear(request: FilmsScreenFlow.OnYearButtonTap.Request) {
        yearForFilter = request.year
        isFilteredByYear = true

        sortOrFilterFilmsByYear() { sortedAndFiltered in
            self.filmsToDisplay = sortedAndFiltered
            self.presenterDoUpdate()

            self.filmsToDisplay = self.allFetchedFilms
        }
    }


    func doSearchFor(request: FilmsScreenFlow.OnSearchBarGlassIconTap.Request) {
        if let searchingText = request.searchText?.lowercased(),
            !searchingText.trimmingCharacters(in: .whitespaces).isEmpty {
            
            isSearching = true

            filteredFilms = filmsToDisplay.filter { film in
                let matchesNameOriginal = film.nameOriginal?.lowercased().contains(searchingText) ?? false

                let matchesCountries = film.countries.contains { country in
                    return country.country.lowercased().contains(searchingText)
                }

                let matchesGenres = film.genres.contains { genre in
                    return genre.genre.lowercased().contains(searchingText)
                }

                return matchesNameOriginal || matchesCountries || matchesGenres
            }
            filmsToDisplay = filteredFilms
        } else {
            isSearching = false
            isFilteredByYear = false // так как показаны все что были загружены и мы можем продолжить скачивать новые, если сортировка по убыванию
            yearForFilter = Constants.defaultYear
            filmsToDisplay = allFetchedFilms
        }

        presenterDoUpdate()
    }

    func onCellTap(request: FilmsScreenFlow.OnSelectItem.Request) {
        idOfSelectedFilm = Int(request.id)
        presenter?.presentRouteToOneFilmDetails(response: FilmsScreenFlow.RoutePayload.Response())
    }

    func didTapLogOff(request: FilmsScreenFlow.OnLogOffBarItemTap.Request) {
        presenter?.presentRouteBackToLoginScreen(response: FilmsScreenFlow.OnSelectItem.Response())
    }

    //MARK: - Private methods

    private func workerLoadFilms(isRefreshRequested: Bool, completion: @escaping ([OneFilm]) -> Void) {

        worker?.loadFilms(isRefreshRequested: isRefreshRequested) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let filmsAndTotal):
                filmsAvailiableToFetch = filmsAndTotal.1
                allFetchedFilms.append(contentsOf: filmsAndTotal.0)

                filmsToDisplay = allFetchedFilms.sorted { $0.ratingKinopoisk ?? 0.1 > $1.ratingKinopoisk ?? 0.0 } // для корректного показа по порядку со склелетонами
                allFetchedFilms = filmsToDisplay //для сохранения всех фильмов и проверки на уникальные
                //здесь картинки еще не загрузили
                completion(filmsToDisplay)
            case .failure(let failure):
                presenter?.presentAlert(response: FilmsScreenFlow.AlertInfo.Response(error: failure))
            }
        }
    }

    private func loadAvatarsFor(films: [OneFilm], completion: @escaping ([OneFilm]) -> Void) {
        presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: true))

        worker?.loadAvatarsFor(films: films) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let filmsWithStringAvatar):
                allFetchedFilms = filmsWithStringAvatar
                
                if !allFetchedFilms.isEmpty {
                    filmsToDisplay = allFetchedFilms.sorted { $0.ratingKinopoisk ?? 0.1 > $1.ratingKinopoisk ?? 0.0 }
                    presenter?.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: false))
                    completion(filmsToDisplay)
                }
            case .failure(let failure):
                presenter?.presentAlert(response: FilmsScreenFlow.AlertInfo.Response(error: failure))
            }
        }
    }

    private func sortOrFilterFilmsByYear(completion: @escaping ([OneFilm]) -> Void) {
        var sortedAndFiltered: [OneFilm]

        if isFilteredByYear {
            sortedAndFiltered = filmsToDisplay.filter { $0.year == yearForFilter }
        } else {
            sortedAndFiltered = filmsToDisplay
        }

        sortedAndFiltered.sort { film1, film2 in
            let rating1 = film1.ratingKinopoisk ?? 0.0
            let rating2 = film2.ratingKinopoisk ?? 0.0

            if rating1 == rating2 {
                return film1.nameOriginal ?? "" < film2.nameOriginal ?? ""
            }
            return isSortedDescending ? rating1 > rating2 : rating1 < rating2
        }
        completion(sortedAndFiltered)
    }


    private func presenterDoUpdate() {
        presenter?.presentUpdate(response: FilmsScreenFlow.Update.Response(
            isNowFilteringAtSearchOrYearOrSortedDescending: isAtSearchingOrFilteredYearOrSortedAscending,
            filmsSortedFiltered: filmsToDisplay,
            yearForFilterAt: yearForFilter))

    }
}
