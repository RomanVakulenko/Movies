//
//  OneFilmDetailsRouter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import UIKit
import SnapKit

protocol OneFilmDetailsRoutingLogic {
    func routeBackToFilmsScreen()
    func routeToWeb()
}

protocol OneFilmDetailsDataPassing {
    var dataStore: OneFilmDetailsDataStore? { get }
}


final class OneFilmDetailsRouter: OneFilmDetailsRoutingLogic, OneFilmDetailsDataPassing {

    weak var viewController: OneFilmDetailsController?
    weak var dataStore: OneFilmDetailsDataStore?

    // MARK: - Public methods

    func routeBackToFilmsScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: false)
        }
    }

    func routeToWeb() {
        if let filmWebUrl = dataStore?.filmWebUrl {
            guard let url = URL(string: filmWebUrl) else {
                print("Invalid URL string: \(filmWebUrl)")
                return
            }

            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("URL opened successfully.")
                } else {
                    print("Failed to open URL.")
                }
            }

        }

    }

}
