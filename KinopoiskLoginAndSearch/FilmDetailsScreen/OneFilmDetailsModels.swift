//
//  OneFilmDetailsModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import DifferenceKit
import UIKit

enum OneFilmDetailsModel {

    struct ViewModel {
        let backViewColor: UIColor
        let backArrow: UIImage
        let coverView: UIImage
        let linkIcon: UIImage

        let filmTitle: NSAttributedString
        let filmRating: NSAttributedString
        let descriptionTitle: NSAttributedString

        let descriptionText: NSAttributedString
        let genres: NSAttributedString
        let yearsAndCountries: NSAttributedString

        let stillTitle: NSAttributedString

        let views: [AnyDifferentiable]
        let items: [AnyDifferentiable]
    }

}
