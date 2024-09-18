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
        let group = DispatchGroup()

        group.enter()
        fetchFilmDetails(filmId: filmId) {
            self.updateAllButStills()
            group.leave()
        }

        group.enter()
        loadFilmImages(filmId: filmId) {
            group.leave()
        }

        group.notify(queue: .global()) {
            self.updateStills()
        }

    }

    func loadNextTwentyStills(request: OneFilmDetailsFlow.OnLoadRequest.Request) {
        loadFilmImages(filmId: filmId) {}
    }



    func didTapWebLink(request: OneFilmDetailsFlow.OnWebLinkTap.Request) {
        if let film = film {
            presenter?.presentRouteToWeb(response: OneFilmDetailsFlow.OnWebLinkTap.Response())
        }
    }


    // MARK: - Private methods

    private func fetchFilmDetails(filmId: Int, completion: @escaping () -> Void) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true, type: .upper))
        //пока не загрузились можно показывать скелетон

        worker?.getFilmDetails(id: filmId) { [weak self] result in
            guard let self = self else { return }
            presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false, type: .upper))

            switch result {
            case .success(let film):
                self.film = film
                if let webUrl = film.webUrl {
                    self.filmWebUrl = webUrl
                }
            case .failure(let error):
                presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: error))
            }
            completion()
        }
    }

    private func loadFilmImages(filmId: Int, completion: @escaping () -> Void) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true, type: .lower))
        //пока не загрузились можно показывать скелетон

        worker?.loadFilmImages(id: filmId) { [weak self] result in
            guard let self = self else { return }
            presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false, type: .lower))

            switch result {
            case .success(let stills):
                self.film?.stills = stills
            case .failure(let error):
                presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: error))
            }
            completion()
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
