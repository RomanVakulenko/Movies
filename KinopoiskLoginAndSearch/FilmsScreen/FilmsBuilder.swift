//
//  FilmsBuilder.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import UIKit

protocol FilmsBuilderProtocol: AnyObject {
    func getController() -> UIViewController
}


final class FilmsBuilder: FilmsBuilderProtocol {

    func getController() -> UIViewController {
        let viewController = FilmsController()

        let networkManager = NetworkManager(networkService: NetworkService(), mapper: DataMapper())
        let networkWorker = FilmsNetworkWorker(networkManager: networkManager)
        let interactor = FilmsInteractor(networkWorker: networkWorker)

        let presenter = FilmsPresenter()
        let worker = FilmsWorker()
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
