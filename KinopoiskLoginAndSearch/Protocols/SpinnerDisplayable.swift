//
//  SpinnerDisplayable.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol SpinnerDisplayable {
    func showSpinner()
    func hideSpinner()
}

extension SpinnerDisplayable where Self: UIView {

    func showSpinner() {
        let spinner: UIActivityIndicatorView

        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .large)
        } else {
            spinner = UIActivityIndicatorView(style: .whiteLarge)
        }

        spinner.startAnimating()

        self.addSubview(spinner)
        spinner.snp.makeConstraints {
            $0.center.equalTo(self)
        }
    }

    func hideSpinner() {
        for view in self.subviews {
            if let spinner = view as? UIActivityIndicatorView {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
            }
        }
    }
}
