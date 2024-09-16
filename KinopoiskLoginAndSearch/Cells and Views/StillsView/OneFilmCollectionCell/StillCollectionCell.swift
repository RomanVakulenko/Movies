//
//  StillCollectionCell.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 15.09.2024.
//

import UIKit
import SnapKit



final class StillCollectionCell: BaseCollectionViewCell<StillCollectionCellViewModel> {

    private enum Constants {
        static let insideCellSpacing: CGFloat = 2
    }

    private(set) lazy var backView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private(set) lazy var oneStillImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()


    // MARK: - Public methods
    override func prepareForReuse() {
        super.prepareForReuse()
        oneStillImageView.image = nil
    }

   override func update(with viewModel: StillCollectionCellViewModel) {
       contentView.backgroundColor = .none
       oneStillImageView.image = viewModel.stillImage
       layoutIfNeeded()
   }

    override func composeSubviews() {
        backgroundColor = .none
        contentView.addSubview(backView)
        backView.addSubview(oneStillImageView)

        let attachmentTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAtStill(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(attachmentTapGestureRecognizer)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        oneStillImageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
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
