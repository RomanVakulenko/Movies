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
    func didPullToReftesh()
    func didTapSortIcon()
    func yearButtonTapped()
    func loadNextFilmsIfAvaliable()
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
        view.backgroundColor = .none
        return view
    }()

    private(set) lazy var sortView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .none
        return view
    }()

    private lazy var searchView: SearchView = {
        let view = SearchView()
        view.backgroundColor = .none
        return view
    }()

    private lazy var yearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .none
        btn.addTarget(self, action: #selector(yearButton_touchUpInside(_:)), for: .touchUpInside)

        return btn
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .none
        return tableView
    }()

    private(set) var viewModel: FilmsModel.ViewModel?

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: GlobalConstants.fetchingFilms)
        control.addTarget(self, action: #selector(didPullToRefresh_valueChanged), for: .valueChanged)
        return control
    }()


    // MARK: - Init

    deinit { }

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = UIHelper.Color.almostBlack
        tableView.refreshControl = self.refreshControl
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

        if yearButton.titleLabel?.attributedText?.string != viewModel.yearButtonText.string { //fixes flashing at update
            yearButton.tintColor = UIHelper.Color.cyanSome // Для шеврона
            yearButton.setAttributedTitle(viewModel.yearButtonText, for: .normal)
            yearButton.layer.cornerRadius = GlobalConstants.cornerRadius
            yearButton.layer.borderColor = UIHelper.Color.gray.cgColor
            yearButton.layer.borderWidth = UIHelper.Margins.small1px
        }
        updateConstraints(insets: viewModel.insets)

        tableView.backgroundColor = viewModel.backViewColor
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func displayWaitIndicator(viewModel: FilmsScreenFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner(type: .center)
        } else {
            hideSpinner()
        }
    }


    // MARK: - Actions
    @objc func didPullToRefresh_valueChanged() {
        output?.didPullToReftesh()
    }

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
        backView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        sortView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(UIHelper.Margins.large26px)
        }

        searchView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(sortView.snp.trailing).offset(UIHelper.Margins.small4px)
            $0.height.equalTo(UIHelper.Margins.huge56px)
        }

        yearButton.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(UIHelper.Margins.medium8px)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(GlobalConstants.fieldsAndButtonHeight48px)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(yearButton.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    ///Must have the same set of constraints as makeConstraints method
    private func updateConstraints(insets: UIEdgeInsets) {
        backView.snp.updateConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(insets.top)
            $0.leading.equalToSuperview().offset(insets.left)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(insets.bottom)
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

//extension FilmsView: UITableViewDelegate {
//
//    // Метод вызывается перед тем, как ячейка будет отображена
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let viewModel = viewModel else { return }
//        let totalRows = tableView.numberOfRows(inSection: 0)
//
//            // Если текущая ячейка находится близко к концу списка (например, 15-я с конца), и не происходит фильтрация
//            if indexPath.row >= totalRows - 15 && !viewModel.isNowFilteringAtSearchOrYearOrSortedDescending {
//                print("Reached near the end of the list at index \(indexPath.row)")
//                output?.loadNextFilms()
//            }
//    }
//}


extension FilmsView: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y // смещение от 0
        let contentHeight = scrollView.contentSize.height // Высота всего контента (всех ячеек)
        let scrollViewHeight = scrollView.frame.size.height // Высота видимой области таблицы

        // Проверяем, достигли ли мы 40% от высоты всего контента
        let threshold = contentHeight * 0.4

        // Если прокручено больше 40% контента
        if offsetY + scrollViewHeight >= threshold,
           let viewModel = viewModel,
           !viewModel.isNowFilteringAtSearchOrYearOrSortedDescending {
            print("Scrolled 40% of the content height")
            output?.loadNextFilmsIfAvaliable()
        }
    }
}


