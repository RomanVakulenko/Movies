//
//  LogInRegistrPresenter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol LogInRegistrPresentationLogic {
    func presentUpdate(response: LogInRegistrFlow.Update.Response)
    func presentAlert(response: LogInRegistrFlow.AlertInfo.Response)
    func presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response)
}


final class LogInRegistrPresenter: LogInRegistrPresentationLogic {


    // MARK: - Public properties
    weak var viewController: LogInRegistrDisplayLogic?

    // MARK: - Public methods
    func presentUpdate(response: LogInRegistrFlow.Update.Response) {
        let backColor = UIHelper.Color.almostBlack

        let placeholderAttributes: [NSAttributedString.Key: Any] = [ .foregroundColor: UIColor.white ]
        let attributedPlaceholderForLogin = NSAttributedString(
            string: GlobalConstants.loginPlaceholder,
            attributes: placeholderAttributes)

        let attributedPlaceholderForPassword = NSAttributedString(
            string: GlobalConstants.passwordPlaceholder,
            attributes: placeholderAttributes)

        let appTitle = NSAttributedString(string: GlobalConstants.appTitle,
                                          attributes: UIHelper.Attributed.cyanSomeBold22)

        let enterButton = NSAttributedString(string: GlobalConstants.enterButton,
                                             attributes: UIHelper.Attributed.whiteInterBold18)
        let enterButtonBackground = UIHelper.Color.cyanSome

        let insets = UIEdgeInsets(top: 0,
                                  left: UIHelper.Margins.medium16px,
                                  bottom: UIHelper.Margins.medium16px,
                                  right: UIHelper.Margins.medium16px)
        let viewModel = LogInRegistrFlow.Update.ViewModel(
            backColor: backColor, 
            emptyForLoginAndPasswordAtLogOff: "",
            attributedPlaceholderForLogin: attributedPlaceholderForLogin,
            attributedPlaceholderForPassword: attributedPlaceholderForPassword,
            appTitle: appTitle,
            enterButton: enterButton,
            enterButtonBackground: enterButtonBackground,
            insets: insets)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayUpdate(viewModel: viewModel)
        }
    }

    func presentAlert(response: LogInRegistrFlow.AlertInfo.Response) {
        let title = GlobalConstants.attention
        var text = ""

        switch response.alertAt {
        case .someFieldIsEmpty:
            text = GlobalConstants.someFieldIsEmpty
        case .invalidPassword:
            text = GlobalConstants.invalidPassword
        }
        let buttonTitle = GlobalConstants.ok

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(
                viewModel: LogInRegistrFlow.AlertInfo.ViewModel(title: title,
                                                                text: text,
                                                                firstButtonTitle: buttonTitle))


        }
    }

    func presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToFilmsScreen(
                viewModel: LogInRegistrFlow.RoutePayload.ViewModel())
        }
    }

}
