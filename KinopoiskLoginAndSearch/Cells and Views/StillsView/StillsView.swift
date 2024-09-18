//
//  StillsView.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import UIKit
import SnapKit

protocol StillsViewOutput: AnyObject,
                           StillCollectionCellViewModelOutput { 

    func loadNextTwentyStills()
}

protocol StillsViewLogic: UIView {
    func update(viewModel: StillsViewModel)
//    func displayWaitIndicator(viewModel: OneEmailAttachmentFlow.OnWaitIndicator.ViewModel)

    var output: StillsViewOutput? { get set }
}


final class StillsView: UIView, StillsViewLogic {

    enum Constants {
        static let cellWidthHeight: CGFloat = 104
    }

    // MARK: - Public properties

    weak var output: StillsViewOutput?
    var viewModel: StillsViewModel?

    // MARK: - Private properties

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIHelper.Color.almostBlack
        return view
    }()

    private(set) lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = UIHelper.Margins.small4px
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: StillCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = UIHelper.Color.almostBlack
        return collectionView
    }()

    // MARK: - Init

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = UIHelper.Color.almostBlack
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func update(viewModel: StillsViewModel) {
        self.viewModel = viewModel
        backView.backgroundColor = UIHelper.Color.almostBlack
        collectionView.backgroundColor = UIHelper.Color.almostBlack
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
            $0.top.leading.trailing.bottom.equalToSuperview()
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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidthHeight = collectionView.bounds.height - UIHelper.Margins.medium8px
        return CGSize(width: cellWidthHeight, height: cellWidthHeight)
    }
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UITableView else { return }

        let visibleRows = collectionView.indexPathsForVisibleRows?.count ?? 0
        let totalRows = collectionView.numberOfRows(inSection: 0)

        if totalRows > 0 && visibleRows > 0 {
            let lastVisibleIndex = collectionView.indexPathsForVisibleRows?.last?.row ?? 0

            // Проверяем, если 11 ячейка из каждых 20 показана
            if lastVisibleIndex >= totalRows - (totalRows / 2) || (lastVisibleIndex % 20 == 10) {
                output?.loadNextTwentyStills()
            }
        }
    }
}
