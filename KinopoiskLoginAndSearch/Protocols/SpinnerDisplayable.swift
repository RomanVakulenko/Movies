//
//  SpinnerDisplayable.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol SpinnerDisplayable {
    func showSpinner(type: SpinnerPlace)
    func hideSpinner()
}

enum SpinnerPlace {
    case center, upper, lower
}

extension SpinnerDisplayable where Self: UIView {

    func showSpinner(type: SpinnerPlace) {
        let spinner: UIActivityIndicatorView

        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .large)
        } else {
            spinner = UIActivityIndicatorView(style: .whiteLarge)
        }

        spinner.startAnimating()
        spinner.color = .white

        self.addSubview(spinner)

        switch type {
        case .center:
            spinner.snp.makeConstraints {
                $0.center.equalTo(self)
            }
        case .upper:
            spinner.snp.makeConstraints {
                $0.center.equalTo(self).offset(-UIHelper.Margins.huge36px)
            }
        case .lower:
            spinner.snp.makeConstraints {
                $0.center.equalTo(self).offset(UIHelper.Margins.huge56px)
            }
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
