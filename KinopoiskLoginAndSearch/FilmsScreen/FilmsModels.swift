//
//  FilmsModels.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import DifferenceKit
import UIKit

enum FilmsModel {

    struct ViewModel {
        let backViewColor: UIColor
        let navBarBackground: UIColor
        let navBar: CustomNavBar

        let yearButtonText: NSAttributedString
        let sortIcon: UIImage

        let items: [AnyDifferentiable]
        let isNowFilteringAtSearchOrYearOrSortedDescending: Bool
        let insets: UIEdgeInsets
    }
}



