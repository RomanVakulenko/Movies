//
//  OneFilmDetailsModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import DifferenceKit
import UIKit

enum OneFilmDetailsModel {

    enum Errors: Error {
        case cantFetchOneEmail
        case errorAtCreatingFolder
        case errorAtAddingToFolder
        case errorAtMovingToFolder
        case errorAtDeleting
    }

    struct ViewModel {
        let navBarBackground: UIColor
        let backViewColor: UIColor
        let navBar: CustomNavBar
        let separatorColor: UIColor
        let hasAttachment: Bool
        let hasFotos: Bool
        
        let views: [AnyDifferentiable]
        let items: [AnyDifferentiable]
        
        let swipeInstructionTextLabel: NSAttributedString
    }

}
