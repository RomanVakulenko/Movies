//
//  AddressBookView.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import UIKit
import SnapKit

protocol AddressBookViewOutput: AnyObject,
                                SearchViewOutput,
                                ContactNameAndAddressCellViewModelOutput {
}

protocol AddressBookViewLogic: UIView {
    func toggleSearchBar(viewModel: SearchViewModel)
    func update(viewModel: AddressBookModel.ViewModel)
    func displayWaitIndicator(viewModel: AddressBookFlow.OnWaitIndicator.ViewModel)

    var output: AddressBookViewOutput? { get set }
}

final class AddressBookView: UIView, AddressBookViewLogic, SpinnerDisplayable {

    // MARK: - Private properties
    private enum Constants {
        static let addHeightForSeparatorTo1pxTotal: CGFloat = 0.67
    }

    private lazy var backView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private lazy var separatorView: UIView = {
        let line = UIView()
        return line
    }()

    private lazy var searchView: SearchView = {
        let view = SearchView()
        return view
    }()

    private let tableView = UITableView()

    private(set) var viewModel: AddressBookModel.ViewModel?


    // MARK: - Init

    deinit { }

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var output: AddressBookViewOutput?

    // MARK: - Public Methods

    func update(viewModel: AddressBookModel.ViewModel) {
        self.viewModel = viewModel

        self.layer.backgroundColor = viewModel.backViewColor.cgColor
        backView.layer.backgroundColor = viewModel.backViewColor.cgColor
        separatorView.layer.borderWidth = UIHelper.Margins.small1px
        separatorView.layer.borderColor = viewModel.separatorColor.cgColor

        tableView.reloadData()
    }

    func toggleSearchBar(viewModel: SearchViewModel) {
        if viewModel.isSearchBarDisplaying {
            backView.addSubview(searchView)

            separatorView.snp.remakeConstraints {
                $0.top.equalTo(backView.snp.top)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(UIHelper.Margins.small1px)
            }

            searchView.snp.makeConstraints {
                $0.top.equalTo(separatorView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }

            tableView.snp.remakeConstraints {
                $0.top.equalTo(searchView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            searchView.removeFromSuperview()
            tableView.snp.remakeConstraints {
                $0.top.equalTo(separatorView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
        searchView.viewModel = viewModel
        searchView.update(viewModel: viewModel)
        searchView.output = output
    }

    func displayWaitIndicator(viewModel: AddressBookFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner()
        } else {
            hideSpinner()
        }
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
        tableView.register(cellType: ContactNameAndAddressCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.isUserInteractionEnabled = true
        tableView.delaysContentTouches = false
    }

    private func addSubviews() {
        self.addSubview(backView)
        [separatorView, tableView].forEach { backView.addSubview($0) }
    }

    private func configureConstraints() {
        let view = self

        backView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        separatorView.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIHelper.Margins.small1px)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource

extension AddressBookView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel?.items[indexPath.row].base

        if let vm = item as? ContactNameAndAddressCellViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as ContactNameAndAddressCell
            cell.viewModel = vm
            cell.viewModel?.output = output
            return cell
        } else {
            return UITableViewCell()
        }
    }

}
