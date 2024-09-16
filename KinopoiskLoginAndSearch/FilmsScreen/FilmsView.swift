//
//  FilmsView.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol FilmsViewOutput: AnyObject,
                          SearchViewOutput,
                          FilmsTableCellViewModelOutput {
    func didTapSortIcon()
    func yearButtonTapped()
    func loadNextTwentyFilms()
}

protocol FilmsViewLogic: UIView {
    func updateSearchView(viewModel: SearchViewModel)
    func update(viewModel: FilmsModel.ViewModel)
    func displayWaitIndicator(viewModel: FilmsScreenFlow.OnWaitIndicator.ViewModel)

    var output: FilmsViewOutput? { get set }
}

final class FilmsView: UIView, FilmsViewLogic, SpinnerDisplayable {

    // MARK: - Private properties

    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private(set) lazy var sortView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var searchView: SearchView = {
        let view = SearchView()
        return view
    }()

    private lazy var yearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = GlobalConstants.cornerRadius
        btn.layer.borderColor = UIHelper.Color.gray.cgColor
        btn.addTarget(self, action: #selector(yearButton_touchUpInside(_:)), for: .touchUpInside)
        return btn
    }()

    private let tableView = UITableView()

    private(set) var viewModel: FilmsModel.ViewModel?


    // MARK: - Init

    deinit { }

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var output: FilmsViewOutput?

    // MARK: - Public Methods

    func updateSearchView(viewModel: SearchViewModel) {
        searchView.viewModel = viewModel
        searchView.update(viewModel: viewModel)
        searchView.output = output
    }

    func update(viewModel: FilmsModel.ViewModel) {
        self.viewModel = viewModel
        self.layer.backgroundColor = viewModel.backViewColor.cgColor
        backView.layer.backgroundColor = viewModel.backViewColor.cgColor
        sortView.image = viewModel.sortIcon

        if yearButton.titleLabel?.attributedText != viewModel.yearButtonText { //fixes flashing at update
            yearButton.setAttributedTitle(viewModel.yearButtonText, for: .normal)
        }
        updateConstraints(insets: viewModel.insets)

        tableView.reloadData()
    }

    func displayWaitIndicator(viewModel: FilmsScreenFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner()
        } else {
            hideSpinner()
        }
    }


    // MARK: - Actions

    @objc func didTapSort_touchUpInside(_ sender: UIButton) {
        output?.didTapSortIcon()
    }

    @objc func yearButton_touchUpInside(_ sender: UIButton) {
        output?.yearButtonTapped()
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
        tableView.register(cellType: FilmsTableCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.isUserInteractionEnabled = true
        tableView.delaysContentTouches = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSort_touchUpInside(_:)))
        sortView.isUserInteractionEnabled = true
        sortView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func addSubviews() {
        self.addSubview(backView)
        [sortView, searchView, yearButton, tableView].forEach { backView.addSubview($0) }
    }

    private func configureConstraints() {
        let view = self
        backView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        sortView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.width.equalTo(GlobalConstants.fieldsAndButtonHeight24px)
        }

        searchView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(sortView.snp.trailing).offset(UIHelper.Margins.small4px)
        }

        yearButton.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(UIHelper.Margins.medium8px)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(GlobalConstants.fieldsAndButtonHeight24px)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(yearButton.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.trailing.bottom.equalToSuperview()
        }
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

// MARK: - UITableViewDataSource

extension FilmsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel?.items[indexPath.row].base

        if let vm = item as? FilmsTableCellViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as FilmsTableCell
            cell.viewModel = vm
            cell.viewModel?.output = output
            return cell
        } else {
            return UITableViewCell()
        }
    }

}


extension FilmsView: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }

        let visibleRows = tableView.indexPathsForVisibleRows?.count ?? 0
        let totalRows = tableView.numberOfRows(inSection: 0)

        if totalRows > 0 && visibleRows > 0 {
            let lastVisibleIndex = tableView.indexPathsForVisibleRows?.last?.row ?? 0

            // Проверяем, если 11 ячейка из каждых 20 показана
            if lastVisibleIndex >= totalRows - (totalRows / 2) || (lastVisibleIndex % 20 == 10) {
                output?.loadNextTwentyFilms()
            }
        }
    }
}
