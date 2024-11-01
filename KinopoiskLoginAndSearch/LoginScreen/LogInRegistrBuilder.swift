//
//  LogInRegistrBuilder.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol LogInRegistrBuilderProtocol: AnyObject {
    func getController() -> UIViewController
}

@available(iOS 13.0, *)
final class LogInRegistrBuilder: LogInRegistrBuilderProtocol {

    func getController() -> UIViewController {
        let viewController = LogInRegistrController()
        let interactor = LogInRegistrInteractor()
        let presenter = LogInRegistrPresenter()
        let worker = LogInRegistrWorker()
        let router = LogInRegistrRouter()
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
