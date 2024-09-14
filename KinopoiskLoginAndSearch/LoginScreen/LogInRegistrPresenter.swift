//
//  LogInRegistrPresenter.swift
//  SGTS
//
//  Created by Roman Vakulenko on 03.04.2024.
//

import UIKit

protocol LogInRegistrPresentationLogic {
    func presentUpdate(response: LogInRegistrFlow.Update.Response)
//    func presentWaitIndicator(response: LogInRegistrFlow.OnWaitIndicator.Response)
    func presentAlert(response: LogInRegistrFlow.AlertInfo.Response)
    func presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response)
}


final class LogInRegistrPresenter: LogInRegistrPresentationLogic {

    enum Constants {}

    // MARK: - Public properties
    weak var viewController: LogInRegistrDisplayLogic?

    // MARK: - Public methods
    func presentUpdate(response: LogInRegistrFlow.Update.Response) {
        let backColor = UIHelper.Color.almostBlack

        let appTitle = NSAttributedString(string: GlobalConstants.appTitle,
                                          attributes: UIHelper.Attributed.cyanSomeBold22)

        let enterButton = NSAttributedString(string: GlobalConstants.enterButton,
                                             attributes: UIHelper.Attributed.whiteMedium16)
        let enterButtonBackground = UIHelper.Color.cyanSome

        let insets = UIEdgeInsets(top: 0,
                                  left: UIHelper.Margins.medium16px,
                                  bottom: UIHelper.Margins.medium16px,
                                  right: UIHelper.Margins.medium16px)
        let viewModel = LogInRegistrFlow.Update.ViewModel(
            backColor: backColor,
            appTitle: appTitle,
            enterButton: enterButton,
            enterButtonBackground: enterButtonBackground,
            insets: insets)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayUpdate(viewModel: viewModel)
        }
    }

    func presentAlert(response: LogInRegistrFlow.AlertInfo.Response) {
        let title = GlobalConstants.error
        let text = GlobalConstants.alertWrongPassword
        let buttonTitle = GlobalConstants.ok

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(viewModel: LogInRegistrFlow.AlertInfo.ViewModel(
                title: title,
                text: text,
                firstButtonTitle: buttonTitle))
        }
    }

    //    func presentWaitIndicator(response: LogInRegistrFlow.OnWaitIndicator.Response) {
    //        DispatchQueue.main.async { [weak self] in
    //            self?.viewController?.displayWaitIndicator(viewModel: LogInRegistrFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
    //        }
    //    }

    func presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToFilmsScreen(
                viewModel: LogInRegistrFlow.RoutePayload.ViewModel())
        }
    }

}
