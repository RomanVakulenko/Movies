//
//  StillsView.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import UIKit
import SnapKit

protocol StillsViewOutput: AnyObject,
                           StillCollectionCellViewModelOutput { }

protocol StillsViewLogic: UIView {
    func update(viewModel: StillsViewModel)
//    func displayWaitIndicator(viewModel: OneEmailAttachmentFlow.OnWaitIndicator.ViewModel)

    var output: StillsViewOutput? { get set }
}


final class StillsView: UIView, StillsViewLogic {

    // MARK: - Public properties

    weak var output: StillsViewOutput?
    var viewModel: StillsViewModel?

    // MARK: - Private properties

    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private(set) lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: StillCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()

    // MARK: - Init

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func update(viewModel: StillsViewModel) {
        self.viewModel = viewModel
//        updateConstraints(insets: viewModel.insets)
        collectionView.reloadData()
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() {
        self.addSubview(backView)
        backView.addSubview(collectionView)
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    ///Must have the same set of constraints as makeConstraints method
//    private func updateConstraints(insets: UIEdgeInsets) {
//        backView.snp.updateConstraints {
//            $0.top.equalToSuperview().offset(insets.top)
//            $0.leading.equalToSuperview().offset(insets.left)
//            $0.bottom.equalToSuperview().inset(insets.bottom)
//            $0.trailing.equalToSuperview().inset(insets.right)
//        }
//    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension StillsView: UICollectionViewDelegateFlowLayout {

//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        guard indexPath.item < cellWidths.count else { return CGSize.zero }
//        let cellWidth = cellWidths[indexPath.item]
//
//        return CGSize(width: cellWidth, height: Constants.collectionViewHeght)
//    }
}


// MARK: - UICollectionViewDataSource

extension StillsView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = viewModel?.items[indexPath.item].base

        if let vm = item as? StillCollectionCellViewModel {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as StillCollectionCell
            cell.viewModel = vm
            cell.viewModel?.output = output
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}
