//
//  FilmsRouter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol FilmsRoutingLogic {
    func routeBackToLoginScreen()
    func routeToOneFilmDetails()
}

protocol FilmsDataPassing {
    var dataStore: FilmsDataStore? { get }
}


final class FilmsRouter: FilmsRoutingLogic, FilmsDataPassing {
    
    weak var viewController: FilmsController?
    weak var dataStore: FilmsDataStore?

    
    // MARK: - Public methods

    
    func routeBackToLoginScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: false)
        }
    }

    func routeToOneFilmDetails() {
        if let oneFilm = dataStore?.oneFilmForOpenDetails {
            let oneFilmViewController =  ().getControllerFor(film: oneFilm)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.navigationController?.pushViewController(oneFilmViewController, animated: true)
            }
        }
    }
    
}
