//
//  FilmsBuilder.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol FilmsBuilderProtocol: AnyObject {
    func getController() -> UIViewController
}


final class FilmsBuilder: FilmsBuilderProtocol {

    func getController() -> UIViewController {
        let viewController = FilmsController()

        let networkManager = NetworkManager(networkService: NetworkService(), mapper: DataMapper())
        let worker = FilmsWorker(networkManager: networkManager)
        let interactor = FilmsInteractor()

        let presenter = FilmsPresenter()
        let router = FilmsRouter()

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
