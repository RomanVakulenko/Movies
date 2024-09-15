//
//  OneFilmDetailsBuilder.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol OneFilmDetailsBuilderProtocol: AnyObject {
    func getControllerFor(film: OneFilm) -> UIViewController
}

final class OneFilmDetailsBuilder: OneFilmDetailsBuilderProtocol {

    func getControllerFor(film: OneFilm) -> UIViewController {
        let viewController = OneFilmDetailsController()
        let interactor = OneFilmDetailsInteractor(film: film)
        let presenter = OneFilmDetailsPresenter()
        let worker = OneFilmDetailsWorker()
        let router = OneFilmDetailsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        return viewController
    }
}
