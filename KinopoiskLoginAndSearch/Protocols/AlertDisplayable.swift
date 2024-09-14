//
//  AlertDisplayable.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol AlertDisplayable: AnyObject {
    func showAlert(title: String?,
                   message: String?,
                   firstButtonTitle: String?,
                   secondButtonTitle: String?,
                   firstButtonCompletion: (() -> Void)?,
                   secondButtonCompletion: (() -> Void)?,
                   completion: (() -> Void)?)
}

extension AlertDisplayable where Self: UIViewController {
    func showAlert(title: String?,
                   message: String?,
                   firstButtonTitle: String? = nil,
                   secondButtonTitle: String? = nil,
                   firstButtonCompletion: (() -> Void)? = nil,
                   secondButtonCompletion: (() -> Void)? = nil,
                   completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let firstTitle = firstButtonTitle {
            let firstAction = UIAlertAction(title: firstTitle,
                                            style: .default) { [weak alert] _ in
                firstButtonCompletion?()
                alert?.dismiss(animated: true,
                               completion: completion)
            }
            alert.addAction(firstAction)
        }

        if let secondTitle = secondButtonTitle {
            let secondAction = UIAlertAction(title: secondTitle,
                                             style: .default) { [weak alert] _ in
                secondButtonCompletion?()
                alert?.dismiss(animated: true,
                               completion: completion)
            }
            alert.addAction(secondAction)
        }

        present(alert, animated: true,
                completion: nil)
    }
}
