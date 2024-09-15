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
    func routeBack()
    func routeToWeb()
}

protocol OneFilmDetailsDataPassing {
    var dataStore: OneFilmDetailsDataStore? { get }
}


final class OneFilmDetailsRouter: OneFilmDetailsRoutingLogic, OneFilmDetailsDataPassing {

    weak var viewController: OneFilmDetailsController?
    weak var dataStore: OneFilmDetailsDataStore?

    // MARK: - Public methods

    func routeBack() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: false)
        }
    }

    func routeToWeb() {

    }
    
}
