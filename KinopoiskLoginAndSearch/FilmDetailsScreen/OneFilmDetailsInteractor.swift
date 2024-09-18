//
//  OneFilmDetailsInteractor.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import UIKit

protocol OneFilmDetailsBusinessLogic {
    func onDidLoadViews(request: OneFilmDetailsFlow.OnDidLoadViews.Request)
    func loadNextTwentyStills(request: OneFilmDetailsFlow.OnLoadRequest.Request)
    func didTapWebLink(request: OneFilmDetailsFlow.OnWebLinkTap.Request)
}


protocol OneFilmDetailsDataStore: AnyObject { 
    var filmWebUrl: String { get }
}


final class OneFilmDetailsInteractor: OneFilmDetailsBusinessLogic, OneFilmDetailsDataStore {

    // MARK: - Public properties

    var presenter: OneFilmDetailsPresentationLogic?
    var worker: OneFilmDetailsWorkingLogic?
    var filmWebUrl = ""

    // MARK: - Private properties

    private var filmId: Int
    private var film: DetailsFilm?

    // MARK: - Lifecycle
    deinit {}

    init(filmId: Int) {
        self.filmId = filmId
    }

    // MARK: - Public methods

    func onDidLoadViews(request: OneFilmDetailsFlow.OnDidLoadViews.Request) {

        fetchFilmDetails(filmId: filmId) { filmWithoutCover in
            self.film = filmWithoutCover
            if let webUrl = filmWithoutCover.webUrl {
                self.filmWebUrl = webUrl
            }
            self.updateAllButStills() //кратковременно или показывает placeholder, если нет cover

            self.downloadAndCacheCover(for: filmWithoutCover) { filmDetailsWithCover in
                self.updateAllButStills()

                self.loadFilmStills(filmId: filmDetailsWithCover.kinopoiskId) { stills in
                    self.film?.stills = stills
                    self.updateStills()
                }
            }
        }
    }


    func loadNextTwentyStills(request: OneFilmDetailsFlow.OnLoadRequest.Request) {
        self.loadFilmStills(filmId: filmId) { stills in
            self.updateStills()
        }
    }

    func didTapWebLink(request: OneFilmDetailsFlow.OnWebLinkTap.Request) {
        if film != nil {
            presenter?.presentRouteToWeb(response: OneFilmDetailsFlow.OnWebLinkTap.Response())
        }
    }


    // MARK: - Private methods

    private func fetchFilmDetails(filmId: Int, completion: @escaping (DetailsFilm) -> Void) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true, type: .upper))

        worker?.getFilmDetails(id: filmId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let film):
//                self.film = film
//                if let webUrl = film.webUrl {
//                    self.filmWebUrl = webUrl
//                }
                presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false, type: .upper))
                completion(film)
            case .failure(let error):
                presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: error))
            }

        }
    }

    private func downloadAndCacheCover(for detailsFilm: DetailsFilm,
                                       completion: @escaping (DetailsFilm) -> Void) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true, type: .upper))
        worker?.downloadAndCacheCover(for: detailsFilm) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let detailsFilmWithStringCover):
                film = detailsFilmWithStringCover
                
//                presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false, type: .upper))
                if let film = film {
                    completion(film)
                }
            case .failure(let failure):

                presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: failure))
            }
            presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false, type: .upper))
        }
    }

    private func loadFilmStills(filmId: Int, completion: @escaping ([OneStill]) -> Void) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true, type: .lower))

        worker?.loadFilmStills(filmId: filmId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let stills):
                self.film?.stills = stills
                presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false, type: .lower))
                completion(stills)
            case .failure(let error):
                presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: error))
            }

        }
    }

    private func updateAllButStills() {
        if let film = film {
            presenter?.presentUpdateAllButStills(response: OneFilmDetailsFlow.UpdateAllButStills.Response(film: film))
        }
    }

    private func updateStills() {
        if let film = film {
            presenter?.presentUpdateStills(response: OneFilmDetailsFlow.UpdateStills.Response(stills: film.stills))
        }
    }
}
