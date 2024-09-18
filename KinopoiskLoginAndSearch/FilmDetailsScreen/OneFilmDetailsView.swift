//
//  OneFilmDetailsView.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import SnapKit

protocol OneFilmDetailsViewOutput: AnyObject,
                                   StillsViewOutput { 
    func didTapChevronBack()
    func didTapWebLink()
}

protocol OneFilmDetailsViewLogic: UIView {
    func updateAllButStills(viewModel: OneFilmDetailsModel.ViewModel)
    func updateStills(viewModel: StillsViewModel)
    func displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel)

    var output: OneFilmDetailsViewOutput? { get set }
}


final class OneFilmDetailsView: UIView, OneFilmDetailsViewLogic, SpinnerDisplayable {

    // MARK: - Public properties

    weak var output: OneFilmDetailsViewOutput?

    // MARK: - Private properties

    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var backChevronView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var coverView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()

    private lazy var filmTitle: UILabel = {
        let view = UILabel()
        return view
    }()

    private lazy var filmRating: UILabel = {
        let view = UILabel()
        return view
    }()

    private lazy var descriptionTitle: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var linkIcon: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var descriptionText: UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var genres: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var yearsAndCountries: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var stillsTitle: UILabel = {
        let view = UILabel()
        return view
    }()

    private lazy var stillsView: StillsView = {
        let view = StillsView()
        return view
    }()

    private(set) var viewModel: OneFilmDetailsModel.ViewModel?
    private(set) var stillsViewModel: StillsViewModel?


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

    
    // MARK: - Public Methods
    
    func updateAllButStills(viewModel: OneFilmDetailsModel.ViewModel) {
        self.viewModel = viewModel
        backgroundColor = viewModel.backViewColor
        backView.backgroundColor = viewModel.backViewColor
    }

    func updateStills(viewModel: StillsViewModel) {
        self.stillsViewModel = viewModel

        for (i, _) in viewModel.items.enumerated() {
            let viewModel = viewModel.items[i].base

            switch viewModel {
            case let vm as StillsViewModel:
                stillsView.viewModel = vm
                stillsView.update(viewModel: vm)
                stillsView.output = output
            default:
                break
            }
        }
    }

    func displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner(type: viewModel.type)
        } else {
            hideSpinner()
        }
    }



    // MARK: - Actions
    @objc private func didTapChevronBack(_ sender: UITapGestureRecognizer) {
        output?.didTapChevronBack()
    }

    @objc private func didTapWebLink(_ sender: UITapGestureRecognizer) {
        output?.didTapWebLink()
    }


      // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()

    }
    
    private func addSubviews() {
        self.addSubview(backView)
        [backChevronView, coverView, filmTitle, filmRating, descriptionTitle, linkIcon, descriptionText, genres, yearsAndCountries, stillsTitle, stillsView].forEach { backView.addSubview($0) }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChevronBack(_:)))
        backChevronView.isUserInteractionEnabled = true
        backChevronView.addGestureRecognizer(tapGestureRecognizer)

        let tapGestureRecognizerAtIcon = UITapGestureRecognizer(target: self, action: #selector(didTapWebLink(_:)))
        linkIcon.isUserInteractionEnabled = true
        linkIcon.addGestureRecognizer(tapGestureRecognizerAtIcon)
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        backChevronView.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top).offset(UIHelper.Margins.large22px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.small6px)
            $0.height.width.equalTo(UIHelper.Margins.large24px)
        }

        coverView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6)
        }

        filmTitle.snp.makeConstraints {
            $0.bottom.equalTo(coverView.snp.bottom).offset(-UIHelper.Margins.medium16px)
            $0.leading.equalTo(coverView.snp.leading).offset(UIHelper.Margins.medium16px)
        }
        filmTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        filmRating.snp.makeConstraints {
            $0.bottom.equalTo(coverView.snp.bottom).offset(-UIHelper.Margins.medium16px)
            $0.trailing.equalTo(coverView.snp.trailing).offset(-UIHelper.Margins.medium16px)
        }

        descriptionTitle.snp.makeConstraints {
            $0.top.equalTo(coverView.snp.bottom).offset(UIHelper.Margins.small6px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
//            $0.trailing.equalTo(linkIcon.snp.leading).offset(-UIHelper.Margins.medium16px)
        }

        linkIcon.snp.makeConstraints {
            $0.top.equalTo(coverView.snp.bottom).offset(UIHelper.Margins.small6px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
            $0.height.width.equalTo(UIHelper.Margins.large24px)
        }

        descriptionText.snp.makeConstraints {
            $0.top.equalTo(descriptionTitle.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
        }

        genres.snp.makeConstraints {
            $0.top.equalTo(descriptionText.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
        }

        yearsAndCountries.snp.makeConstraints {
            $0.top.equalTo(genres.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
        }

        stillsTitle.snp.makeConstraints {
            $0.top.equalTo(yearsAndCountries.snp.bottom).offset(UIHelper.Margins.large22px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
        }

        stillsView.snp.makeConstraints {
            $0.top.equalTo(yearsAndCountries.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.bottom.equalToSuperview().offset(UIHelper.Margins.medium16px)
        }
    }
}

