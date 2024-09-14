//
//  LogInRegistrRouter.swift
//  SGTS
//
//  Created by Roman Vakulenko on 03.04.2024.
//

import UIKit

protocol LogInRegistrRoutingLogic {
    func routeToFilmsScreen()
}

protocol LogInRegistrDataPassing {
    var dataStore: LogInRegistrDataStore? { get }
}


final class LogInRegistrRouter: LogInRegistrRoutingLogic, LogInRegistrDataPassing {

    // MARK: - Public properties
    weak var viewController: LogInRegistrController?
    weak var dataStore: LogInRegistrDataStore?

    // MARK: - Public methods
    func routeToFilmsScreen() {

        let controller = FilmsBuilder().getController()
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.pushViewController(controller, animated: true)
        }


    }
}
