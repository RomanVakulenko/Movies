//
//  StillCollectionCell.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 15.09.2024.
//

import UIKit
import SnapKit

#warning("делать")
final class StillCollectionCell: BaseCollectionViewCell<StillCollectionCellViewModel> {

    enum Constants {
        static let cornerRadius: CGFloat = 11 //in figma 42!!!!- is wrong
        static let topBottomOffset: CGFloat = 5
        static let leftRightInset: CGFloat = 8
        static let insideCellSpacing: CGFloat = 2
        static let imageWidth: CGFloat = 12
    }

    private(set) lazy var backView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()

    private(set) lazy var stillView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()


    // MARK: - Public methods

   override func update(with viewModel: StillCollectionCellViewModel) {
       contentView.backgroundColor = .none
       stillView.image = viewModel.still
       layoutIfNeeded()
   }

    override func composeSubviews() {
        backgroundColor = .none
        contentView.addSubview(backView)
        backView.addSubview(stillView)

        let attachmentTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAtStill(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(attachmentTapGestureRecognizer)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        stillView.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top).offset(Constants.topBottomOffset)
            $0.bottom.equalTo(backView.snp.bottom).inset(Constants.topBottomOffset)
            $0.leading.equalTo(backView.snp.leading).offset(UIHelper.Margins.medium8px)
            $0.width.height.equalTo(UIHelper.Margins.medium12px)
        }
    }

    // MARK: - Private methods

    @objc private func didTapAtStill(_ sender: UITapGestureRecognizer) {
        viewModel?.didTapStill()
    }
    ///Must have the same set of constraints as makeConstraints method
    private func updateConstraints(insets: UIEdgeInsets) {
        backView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(insets.top)
            $0.leading.equalToSuperview().offset(insets.left)
            $0.bottom.equalToSuperview().inset(insets.bottom)
            $0.trailing.equalToSuperview().inset(insets.right)
        }
    }
}
