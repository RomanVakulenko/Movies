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

    private var film: OneFilm?


    // MARK: - Lifecycle
    deinit {}

    init(film: OneFilm) {
        self.film = film
    }

    // MARK: - Public methods

    func onDidLoadViews(request: OneFilmDetailsFlow.OnDidLoadViews.Request) {
        presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: true))

        //Для отображения каждого кадра использовать одно поле API
        worker?.getImagesFor(filmId: Int) { [weak self] result in
            guard let self = self else { return }
            self.presenter?.presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response(isShow: false))

            switch result {
            case .success(let images):


                //                self.presenter?.presentUpdate(response: OneFilmDetailsFlow.Update.Response


            case .failure(let failure):

                self.presenter?.presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response(error: failure))
            }
        }
    }


    func didTapWebLink(request: OneFilmDetailsFlow.OnWebLinkTap.Request) {

        presenter?.presentRouteToSaveDialog(response: OneFilmDetailsFlow.OnWebLinkTap.Response())
    }

}
