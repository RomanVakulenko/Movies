//
//  LogInRegistrView.swift
//  SGTS
//
//  Created by Roman Vakulenko on 02.04.2024.
//

import UIKit
import SnapKit

protocol LogInRegistrViewOutput: AnyObject {
    func enterButtonTapped()
}

protocol LogInRegistrViewLogic: UIView {
    func update(viewModel: LogInRegistrModel.ViewModel)
//    func displayWaitIndicator(viewModel: LogInRegistrFlow.OnWaitIndicator.ViewModel)

    var output: LogInRegistrViewOutput? { get set }
}


final class LogInRegistrView: UIView, LogInRegistrViewLogic {

    enum Constants {
        static let borderWidth: CGFloat = UIHelper.Margins.small1px
        static let cornerRadius: CGFloat = UIHelper.Margins.medium8px
        static let leftViewWidth: CGFloat = 15
        static let fieldFontSize: CGFloat = UIHelper.Margins.medium16px
        static let fieldsAndButtonHeight: CGFloat = UIHelper.Margins.large24px
        static let appTitleOffset: CGFloat = 128
    }

    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var appTitle: UILabel = {
        var lbl = UILabel()
        lbl.textAlignment = .center
        return lbl
    }()

    private lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIHelper.Color.gray
        textField.placeholder = GlobalConstants.loginPlaceholder
        textField.font = UIFont(name: "SFUIDisplay-Regular", size: Constants.fieldFontSize)
        textField.layer.borderColor = UIHelper.Color.gray.cgColor
        textField.layer.borderWidth = Constants.borderWidth
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: Constants.leftViewWidth,
                                                  height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()

    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIHelper.Color.gray
        textField.placeholder = GlobalConstants.passwordPlaceholder
        textField.font = UIFont(name: "SFUIDisplay-Regular", size: Constants.fieldFontSize)
        textField.layer.borderColor = UIHelper.Color.gray.cgColor
        textField.layer.borderWidth = Constants.borderWidth
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: Constants.leftViewWidth,
                                                  height: textField.frame.height))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = true
        return textField
    }()

    private lazy var enterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = Constants.cornerRadius
        btn.addTarget(self, action: #selector(enterButton_touchUpInside(_:)), for: .touchUpInside)
        return btn
    }()

    

    // MARK: - Init

    private(set) var viewModel: LogInRegistrModel.ViewModel?

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Methods

    weak var output: LogInRegistrViewOutput?

    // MARK: - Actions

    @objc func enterButton_touchUpInside(_ sender: UIButton) {
        output?.enterButtonTapped()
    }

    // MARK: - Public Methods

    func update(viewModel: LogInRegistrModel.ViewModel) {
        self.viewModel = viewModel
        backView.backgroundColor = viewModel.backColor
        appTitle.attributedText = viewModel.appTitle
        enterButton.setAttributedTitle(viewModel.enterButton, for: .normal)
        enterButton.layer.backgroundColor = viewModel.enterButtonBackground.cgColor

        updateConstraints(insets: viewModel.insets)
    }
    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() {
        self.addSubview(backView)
        [appTitle, loginTextField, passwordTextField, enterButton].forEach { backView.addSubview($0)}
    }

    private func configureConstraints() {
        let view = self
        backView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        appTitle.snp.makeConstraints {
            $0.top.equalTo(loginTextField.snp.top).offset(-Constants.appTitleOffset)
            $0.centerX.equalTo(backView.snp.centerX)
        }

        loginTextField.snp.makeConstraints {
            $0.centerY.equalTo(backView.snp.centerY)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.fieldsAndButtonHeight)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(loginTextField.snp.bottom).offset(UIHelper.Margins.medium8px)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.fieldsAndButtonHeight)
        }

        enterButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(-Constants.appTitleOffset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.fieldsAndButtonHeight)
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
