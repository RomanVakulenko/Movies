//
//  SearchView.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol SearchViewOutput: AnyObject {
    func didTapAtSearchIconInSearchView(searchText: String)
}

protocol SearchViewLogic: UIView {
    func update(viewModel: SearchViewModel)
//    func displayWaitIndicator(viewModel: NewEmailCreateHeaderFlow.OnWaitIndicator.ViewModel)

    var output: SearchViewOutput? { get set }
}


final class SearchView: UIView, SearchViewLogic {

    // MARK: - Public properties

    var viewModel: SearchViewModel?
    weak var output: SearchViewOutput?

    // MARK: - Private properties

    private enum Constants {
        static let heightOfBackViewForSearch72px: CGFloat = 72
    }

    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var topSeparatorAtSearchBar: UIView = {
        let line = UIView()
        return line
    }()

    private(set) lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.delegate = self
        view.searchTextField.font = UIHelper.Font.RobotoRegular16
        view.searchTextField.leftView = nil
        view.showsCancelButton = false
        return view
    }()

    private lazy var bottomSeparatorAtSearchBar: UIView = {
        let line = UIView()
        return line
    }()

    // MARK: - Init

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public Methods
    func update(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        backView.layer.backgroundColor = viewModel.backColor.cgColor

        searchBar.searchTextField.attributedPlaceholder = viewModel.searchBarAttributedPlaceholder

        searchBar.text = viewModel.searchText
        searchBar.backgroundImage = UIImage() //fixes topSeparator problem

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = viewModel.searchTextColor
            textfield.backgroundColor = viewModel.backColor
            textfield.layer.cornerRadius = UIHelper.Margins.medium8px
            textfield.layer.borderColor = viewModel.separatorColor.cgColor
            textfield.layer.borderWidth = UIHelper.Margins.small1px

            let searchIconView = UIImageView(image: viewModel.searchIcon)
            searchIconView.contentMode = .scaleAspectFit
            searchIconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            textfield.rightView = searchIconView
            textfield.clearButtonMode = .never
            textfield.rightViewMode = .always

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAtSearchIcon(_:)))
            searchIconView.isUserInteractionEnabled = true
            searchIconView.addGestureRecognizer(tapGestureRecognizer)

        }
        bottomSeparatorAtSearchBar.backgroundColor = viewModel.separatorColor

        updateConstraints(insets: viewModel.insets)
    }

    // MARK: - Actions

    @objc private func didTapAtSearchIcon(_ sender: UITapGestureRecognizer) {
        if let text = searchBar.text {
            output?.didTapAtSearchIconInSearchView(searchText: text.lowercased())
        }
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() {
        self.addSubview(backView)
        [topSeparatorAtSearchBar, searchBar, bottomSeparatorAtSearchBar].forEach { backView.addSubview($0) }

    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Constants.heightOfBackViewForSearch72px)
        }

        searchBar.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top)
            $0.leading.equalTo(backView.snp.leading).offset(UIHelper.Margins.medium8px)
            $0.trailing.equalTo(backView.snp.trailing).inset(UIHelper.Margins.medium8px)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(UIHelper.Margins.huge40px)
        }

        bottomSeparatorAtSearchBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIHelper.Margins.small1px)
        }
    }

    private func updateConstraints(insets: UIEdgeInsets) {
        backView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(insets.top)
            $0.leading.equalToSuperview().offset(insets.left)
            $0.bottom.equalToSuperview().inset(insets.bottom)
            $0.trailing.equalToSuperview().inset(insets.right)
        }
    }
}


// MARK: - UITextFieldDelegate
extension SearchView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        output?.didTapAtSearchIconInSearchView(searchText: searchText.lowercased())
        searchBar.resignFirstResponder()
    }
}
