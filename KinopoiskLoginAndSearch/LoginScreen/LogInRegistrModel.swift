//
//  LogInRegistrModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

enum LogInRegistrModel {

    enum AlertAt {
        case someFieldIsEmpty
        case invalidPassword
    }

    struct ViewModel {
        let backColor: UIColor
        let emptyForLoginAndPasswordAtLogOff: String
        let attributedPlaceholderForLogin: NSAttributedString
        let attributedPlaceholderForPassword: NSAttributedString
        let appTitle: NSAttributedString
        let enterButton: NSAttributedString
        let enterButtonBackground: UIColor
        let insets: UIEdgeInsets
    }

}
