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
    func markAsUnread(request: OneFilmDetailsFlow.OnEnvelopNavBarButton.Request)
    func didTapTrashNavBarIcon(request: OneFilmDetailsFlow.OnTrashNavBarIcon.Request)

    func didTapChevronAdresses(request: OneFilmDetailsFlow.OnChevronTapped.Request)
    func didTapAtFileOrFoto(request: OneFilmDetailsFlow.OnAttachedFileOrImageTapped.Request)
    func didTapDownloadIcon(request: OneFilmDetailsFlow.OnDownloadIconOrToSaveAttachedFile.Request)
    func didTapQuattroIcon(request: OneFilmDetailsFlow.OnQuattroIcon.Request)

    func didTapReplyButton(request: OneFilmDetailsFlow.OnReplyButton.Request)
    func didTapReplyToAllButton(request: OneFilmDetailsFlow.OnReplyToAllButton.Request)
    func didTapForwardButton(request: OneFilmDetailsFlow.OnForwardButton.Request)
}


protocol OneFilmDetailsDataStore: AnyObject { }


final class OneFilmDetailsInteractor: OneFilmDetailsBusinessLogic, OneFilmDetailsDataStore {

    // MARK: - Public properties

    var presenter: OneFilmDetailsPresentationLogic?
    var worker: OneFilmDetailsWorkingLogic?

    // MARK: - Private properties

    private var filmId: Int
    private var film: DetailsFilm?
    private var stills: [OneStill]?


    // MARK: - Lifecycle
    deinit {}

    init(filmId: Int) {
        self.filmId = filmId
    }

    // MARK: - Public methods

    func onDidLoadViews(request: OneFilmDetailsFlow.OnDidLoadViews.Request) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true))

        worker?.getFilmDetails(id: filmId) { [weak self] result in
            guard let self = self else { return }
            presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false))

            switch result {
            case .success(let film):
                self.film = film

                worker?.loadFilmImages(id: film.kinopoiskId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let stills):
                        self.stills = stills
                        presenterDoUpdate()

                    case .failure(let failure):
                        presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: failure))
                    }
                }

            case .failure(let failure):
                presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: failure))
            }
        }
    }



    func didTapWebLink(request: OneFilmDetailsFlow.OnWebLinkTap.Request) {
        if let film = film {
            presenter?.presentRouteToSaveDialog(response: OneFilmDetailsFlow.OnWebLinkTap.Response(webUrl: film.webUrl))
        }
    }


    // MARK: - Private methods

    private func presenterDoUpdate() {
        if let film = film {
            presenter?.presentUpdate(response: OneFilmDetailsFlow.Update.Response(
                film: film,
                stills: stills))
        }
    }
}
