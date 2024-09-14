//
//  OneEmailDetailsView.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import UIKit
import SnapKit

protocol OneEmailDetailsViewOutput: AnyObject,
                                    OneEmailDetailsUpperViewOutput,
                                    OneEmailAttachmentViewOutput,
                                    FotoCellViewModelOutput,
                                    OneEmailDetailsButtonsViewOutput { }

protocol OneEmailDetailsViewLogic: UIView {
    func update(viewModel: OneEmailDetailsModel.ViewModel)
    func displayWaitIndicator(viewModel: OneEmailDetailsFlow.OnWaitIndicator.ViewModel)
    
    var output: OneEmailDetailsViewOutput? { get set }
}


final class OneEmailDetailsView: UIView, OneEmailDetailsViewLogic, SpinnerDisplayable {
    
    private enum Constants {
        static let upperViewHeight165px: CGFloat = 1 + 88 + 8 + 67 + 1//1 - bottomSeparator
        static let attachmentViewHeight62px: CGFloat = 8 + 46 + 8
        static let swipeInstructionTextHeight74px: CGFloat = 74
    }

    // MARK: - Public properties

    weak var output: OneEmailDetailsViewOutput?

    // MARK: - Private properties

    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var navBarSeparatorView: UIView = {
        let line = UIView()
        return line
    }()

    private lazy var upperView: OneEmailDetailsUpperView = {
        let view = OneEmailDetailsUpperView()
        return view
    }()

    private lazy var attachmentView: OneEmailAttachmentView = {
        let view = OneEmailAttachmentView()
        return view
    }()

    private let tableView = UITableView()

    private lazy var separatorUnderTableView: UIView = {
        let line = UIView()
        return line
    }()

    private lazy var buttonsView: OneEmailDetailsButtonsView = {
        let view = OneEmailDetailsButtonsView()
        return view
    }()

    private lazy var separatorUnderButtonsView: UIView = {
        let line = UIView()
        return line
    }()
    
    private lazy var swipeInstructionText: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()

    private(set) var viewModel: OneEmailDetailsModel.ViewModel?

    private var tableViewHeight: CGFloat = 0

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

    
    // MARK: - Public Methods
    
    func update(viewModel: OneEmailDetailsModel.ViewModel) {
        self.viewModel = viewModel
        backgroundColor = viewModel.backViewColor
        backView.backgroundColor = viewModel.backViewColor
        navBarSeparatorView.layer.borderColor = viewModel.separatorColor.cgColor
        navBarSeparatorView.layer.borderWidth = UIHelper.Margins.small1px


        for (i, _) in viewModel.views.enumerated() {
            let viewModel = viewModel.views[i].base

            switch viewModel {
            case let vm as OneEmailDetailsUpperModel.ViewModel:
                upperView.viewModel = vm
                upperView.update(viewModel: vm)
                upperView.output = output

            case let vm as OneEmailAttachmentViewModel:
                attachmentView.viewModel = vm
                attachmentView.update(viewModel: vm)
                attachmentView.output = output
                
            case let vm as OneEmailDetailsButtonsViewModel:
                buttonsView.viewModel = vm
                buttonsView.update(viewModel: vm)
                buttonsView.output = output

            default:
                break
            }
        }

        separatorUnderTableView.layer.borderColor = viewModel.separatorColor.cgColor
        separatorUnderTableView.layer.borderWidth = UIHelper.Margins.small1px
        separatorUnderButtonsView.layer.borderColor = viewModel.separatorColor.cgColor
        separatorUnderButtonsView.layer.borderWidth = UIHelper.Margins.small1px
        
        swipeInstructionText.attributedText = viewModel.swipeInstructionTextLabel

        tableViewHeight = calculateTableViewHeightForBodyAndFoto(hasAttachment: viewModel.hasAttachment, hasFotosCell: viewModel.hasFotos)

        if viewModel.hasAttachment {
            backView.addSubview(attachmentView)

            attachmentView.snp.makeConstraints {
                $0.top.equalTo(upperView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }

            tableView.snp.remakeConstraints {
                $0.top.equalTo(attachmentView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }
        } else {
            attachmentView.removeFromSuperview()
            tableView.snp.remakeConstraints {
                $0.top.equalTo(upperView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }
        }

        if viewModel.hasFotos {
            tableView.register(cellType: FotoCell.self)
        }

        tableView.reloadData()
    }
    
    func displayWaitIndicator(viewModel: OneEmailDetailsFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner()
        } else {
            hideSpinner()
        }
    }
      // MARK: - Private Methods

    private func calculateTableViewHeightForBodyAndFoto(hasAttachment: Bool, hasFotosCell: Bool) -> CGFloat {
        let backViewHeight = backView.frame.height
        let navBarSeparatorHeight = navBarSeparatorView.frame.height
        let upperViewHeight = Constants.upperViewHeight165px
        var attachmentViewHeight: CGFloat = 0.0
        if hasAttachment {
            attachmentViewHeight = Constants.attachmentViewHeight62px
        }
        let separatorUnderTableViewHeight = separatorUnderTableView.frame.height
        let buttonsViewHeight = buttonsView.frame.height
        let separatorUnderButtonsViewHeight = separatorUnderButtonsView.frame.height
        let swipeInstructionTextLabelHeight = Constants.swipeInstructionTextHeight74px

        let totalHeightExceptTableView = navBarSeparatorHeight + upperViewHeight + attachmentViewHeight + separatorUnderTableViewHeight + buttonsViewHeight + separatorUnderButtonsViewHeight + swipeInstructionTextLabelHeight

        var heightForTableView = backViewHeight - totalHeightExceptTableView
        if hasFotosCell {
            heightForTableView = (heightForTableView / 2)
        }
        return heightForTableView
    }

    private func configure() {
        addSubviews()
        configureConstraints()
        tableView.register(cellType: TextFieldCell.self)
        tableView.register(cellType: CellWithWKWebView.self)
        tableView.register(cellType: FotoCell.self)
        tableView.register(cellType: SeparatorCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.delaysContentTouches = false
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(reloadTableView),
                                               name: .wkWebViewDidFinishLoading,
                                               object: nil)
    }

    @objc private func reloadTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func addSubviews() {
        self.addSubview(backView)
        [navBarSeparatorView, upperView, tableView, separatorUnderTableView, buttonsView, separatorUnderButtonsView, swipeInstructionText].forEach { backView.addSubview($0) }
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        navBarSeparatorView.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top)
            $0.height.equalTo(UIHelper.Margins.small1px)
            $0.leading.trailing.equalToSuperview()
        }

        upperView.snp.makeConstraints {
            $0.top.equalTo(navBarSeparatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(upperView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        separatorUnderTableView.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.height.equalTo(UIHelper.Margins.small1px)
            $0.leading.trailing.equalToSuperview()
        }

        buttonsView.snp.makeConstraints {
            $0.top.equalTo(separatorUnderTableView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        separatorUnderButtonsView.snp.makeConstraints {
            $0.top.equalTo(buttonsView.snp.bottom)
            $0.height.equalTo(UIHelper.Margins.small1px)
            $0.leading.trailing.equalToSuperview()
        }

        swipeInstructionText.snp.makeConstraints {
            $0.top.equalTo(separatorUnderButtonsView.snp.bottom).offset(UIHelper.Margins.medium16px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().inset(UIHelper.Margins.medium16px)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(UIHelper.Margins.medium16px)
        }
    }
}


// MARK: - UITableViewDataSource

extension OneEmailDetailsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel?.items[indexPath.row].base

        if let vm = item as? TextFieldCellViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as TextFieldCell
            cell.viewModel = vm
            return cell
        } else if let vm = item as? CellWithWKWebViewViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as CellWithWKWebView
//            cell.updateBodyHeightForWebView(height: 200) //todo: what height use??
            cell.viewModel = vm
            return cell
        } else if let vm = item as? FotoCellViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as FotoCell
            cell.viewModel = vm
            cell.viewModel?.output = output
            return cell
        } else if let vm = item as? SeparatorCellViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as SeparatorCell
            cell.viewModel = vm
            return cell
        } else {
            return UITableViewCell()
        }
    }
}


