//
//  BaseCollectionViewCell.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//


import UIKit
import Reusable

open class BaseCollectionViewCell<T>: UICollectionViewCell, Reusable {

    public var viewModel: T? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            update(with: viewModel)
        }
    }

    required public override init(frame: CGRect) {
        super.init(frame: frame)
        initCell()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initCell() {
        backgroundColor = .clear

        composeSubviews()
        setConstraints()
    }

    open func composeSubviews() {}

    open func setConstraints() {}

    open func update(with viewModel: T) {}

}
