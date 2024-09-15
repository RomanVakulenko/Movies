//
//  BaseTableViewCell.swift
//  aisoip
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import Reusable

open class BaseTableViewCell<T>: UITableViewCell, Reusable {
    
    public var viewModel: T? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            update(with: viewModel)
        }
    }
    
    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    private func initCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        composeSubviews()
        setConstraints()
    }
    
    open func composeSubviews() {}
    
    open func setConstraints() {}
    
    open func update(with viewModel: T) {}

}
