//
//  LogInRegistrBuilder.swift
//  SGTS
//
//  Created by Roman Vakulenko on 03.04.2024.
//

import UIKit

protocol LogInRegistrBuilderProtocol: AnyObject {
    func getController() -> UIViewController
}

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
