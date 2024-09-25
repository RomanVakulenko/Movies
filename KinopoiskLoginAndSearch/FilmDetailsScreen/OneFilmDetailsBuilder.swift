//
//  OneFilmDetailsBuilder.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol OneFilmDetailsBuilderProtocol: AnyObject {
    func getControllerFor(filmId: Int) -> UIViewController
}

final class OneFilmDetailsBuilder: OneFilmDetailsBuilderProtocol {

    func getControllerFor(filmId: Int) -> UIViewController {
        let viewController = OneFilmDetailsController()
        let coreDataManager = StorageDataManager()
        
        let networkManager = NetworkManager()
        let worker = OneFilmDetailsWorker(networkManager: networkManager)
        let interactor = OneFilmDetailsInteractor(filmId: filmId)
        let presenter = OneFilmDetailsPresenter()
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
