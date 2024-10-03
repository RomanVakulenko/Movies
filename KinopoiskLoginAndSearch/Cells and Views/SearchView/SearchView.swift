//
//  SearchView.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol SearchViewOutput: AnyObject {
    func doSearchFor(searchText: String)
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

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        return view
    }()

    private(set) lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.backgroundColor = .none
        view.delegate = self
        view.searchTextField.font = UIHelper.Font.InterMedium14
        view.searchTextField.leftView = nil
        view.showsCancelButton = false
        view.isHidden = true
        return view
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
    func update(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        backView.layer.backgroundColor = viewModel.backColor.cgColor
        searchBar.searchTextField.attributedPlaceholder = viewModel.searchBarAttributedPlaceholder
//        searchBar.text = viewModel.searchText
        searchBar.backgroundImage = UIImage()

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = viewModel.searchTextColor
            textfield.backgroundColor = viewModel.backColor
            textfield.layer.cornerRadius = GlobalConstants.cornerRadius
            textfield.layer.borderColor = UIHelper.Color.gray.cgColor
            textfield.layer.borderWidth = GlobalConstants.borderWidth

            let searchIconView = UIImageView(image: viewModel.searchIcon)
            searchIconView.contentMode = .scaleAspectFit
            searchIconView.frame = CGRect(x: 0, 
                                          y: 0,
                                          width: UIHelper.Margins.large20px,
                                          height: UIHelper.Margins.large20px)
            textfield.rightView = searchIconView
            textfield.clearButtonMode = .never
            textfield.rightViewMode = .always
            searchIconView.tintColor = UIHelper.Color.cyanSome

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAtSearchIcon(_:)))
            searchIconView.isUserInteractionEnabled = true
            searchIconView.addGestureRecognizer(tapGestureRecognizer)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in //fixes searchView appearing for a moment earlier than the view
            guard let self = self else {return}
            searchBar.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func didTapAtSearchIcon(_ sender: UITapGestureRecognizer) {
        if let text = searchBar.text {
            output?.doSearchFor(searchText: text.lowercased())
        }
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() {
        self.addSubview(backView)
        backView.addSubview(searchBar)
    }

    private func configureConstraints() {
        let view = self

        backView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(UIHelper.Margins.medium8px)
        }

        searchBar.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(GlobalConstants.fieldsAndButtonHeight48px)
        }
    }
}


// MARK: - UITextFieldDelegate
extension SearchView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText
        output?.doSearchFor(searchText: searchText.lowercased())
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        output?.doSearchFor(searchText: searchText.lowercased())
        searchBar.resignFirstResponder()
    }
}
