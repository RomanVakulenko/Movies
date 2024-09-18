//
//  FilmsTableCell.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol FilmsCollectionCellOutput: AnyObject { }

final class FilmsTableCell: BaseTableViewCell<FilmsTableCellViewModel> {

    // MARK: - SubTypes
    private enum Constants {
        static let mainImageWidthHeight: CGFloat = UIScreen.main.bounds.width / 3
    }

    private(set) lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private(set) lazy var filmImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private(set) lazy var filmTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private(set) lazy var subtitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 0
        return view
    }()

    private(set) lazy var rating: UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        return view
    }()


    // MARK: - Public properties

    weak var output: FilmsCollectionCellOutput?

    // MARK: - Public methods

    override func prepareForReuse() {
        super.prepareForReuse()
        filmImageView.image = nil
        filmTitle.text = nil
        subtitle.text = nil
        rating.text = nil
    }

    override func update(with viewModel: FilmsTableCellViewModel) {
        contentView.backgroundColor = .none
        filmImageView.image = viewModel.filmImage
        filmTitle.attributedText = viewModel.filmTitle
        subtitle.attributedText = viewModel.subtitle
        rating.attributedText = viewModel.rating

        updateConstraints(insets: viewModel.insets)
    }

    override func composeSubviews() {
        contentView.addSubview(backView)
        [filmImageView, filmTitle, subtitle, rating].forEach { backView.addSubview($0) }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAtCell(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        filmImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.height.equalTo(Constants.mainImageWidthHeight)
        }

        filmTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(filmImageView.snp.trailing).offset(UIHelper.Margins.medium8px)
            $0.trailing.equalToSuperview()
//            $0.height.equalTo(GlobalConstants.fieldsAndButtonHeight48px)
        }

        subtitle.snp.makeConstraints {
            $0.top.equalTo(filmTitle.snp.bottom).offset(UIHelper.Margins.medium8px)
            $0.leading.equalTo(filmTitle.snp.leading)
            $0.trailing.equalToSuperview()
        }
        subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        rating.snp.makeConstraints {
            $0.bottom.equalTo(filmImageView.snp.bottom)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIHelper.Margins.huge42px)
            $0.height.equalTo(GlobalConstants.fieldsAndButtonHeight48px)
        }
    }

    // MARK: - Actions
    @objc private func didTapAtCell(_ sender: UITapGestureRecognizer) {
        viewModel?.didTapCell()
    }

    // MARK: - Private methods
    ///Must have the same set of constraints as makeConstraints method
    private func updateConstraints(insets: UIEdgeInsets) {
        backView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(insets.top) //нужны верхний и нижний, а у таблицы убрать верхний и нижний
            $0.leading.equalToSuperview().offset(insets.left)
            $0.bottom.equalToSuperview().inset(insets.bottom)
            $0.trailing.equalToSuperview().inset(insets.right)
        }
    }
}
