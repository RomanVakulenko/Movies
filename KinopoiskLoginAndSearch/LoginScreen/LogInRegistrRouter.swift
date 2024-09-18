//
//  LogInRegistrRouter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol LogInRegistrRoutingLogic {
    func routeToFilmsScreen()
}

protocol LogInRegistrDataPassing {
    var dataStore: LogInRegistrDataStore? { get }
}


@available(iOS 13.4, *)
final class LogInRegistrRouter: LogInRegistrRoutingLogic, LogInRegistrDataPassing {

    // MARK: - Public properties
    weak var viewController: LogInRegistrController?
    weak var dataStore: LogInRegistrDataStore?

    // MARK: - Public methods
    func routeToFilmsScreen() {

        let controller = FilmsBuilder().getController(delegate: viewController)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.pushViewController(controller, animated: true)
        }


    }
}
