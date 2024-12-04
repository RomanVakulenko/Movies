//
//  LogInRegistrInteractor.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol LogInRegistrBusinessLogic {
    func onDidLoadViews(request: LogInRegistrFlow.OnDidLoadViews.Request)
    func useCurrent(loginText: String, passwordText: String)
    func enterButtonTapped(request: LogInRegistrFlow.OnEnterButtonTap.Request)
    func doLoginAndPasswordEmpty(request: LogInRegistrFlow.OnDidLoadViews.Request)
    func logOut()
}

protocol LogInRegistrDataStore: AnyObject {}


final class LogInRegistrInteractor: LogInRegistrBusinessLogic, LogInRegistrDataStore {

    // MARK: - Public properties
    var presenter: LogInRegistrPresentationLogic?
    var worker: LogInRegistrWorkingLogic?

    // MARK: - Private properties
    var loginText: String? = ""
    var passwordText: String? = ""

    private let keychain = KeychainKino.shared
    private let userPreferences = UserPreferences.shared

    func onDidLoadViews(request: LogInRegistrFlow.OnDidLoadViews.Request) {
        presenter?.presentUpdate(response: LogInRegistrFlow.Update.Response())
    }

    func useCurrent(loginText: String, passwordText: String) {
        self.loginText = loginText
        self.passwordText = passwordText
    }

    func doLoginAndPasswordEmpty(request: LogInRegistrFlow.OnDidLoadViews.Request) {
        presenter?.presentUpdate(response: LogInRegistrFlow.Update.Response())
    }

    func enterButtonTapped(request: LogInRegistrFlow.OnEnterButtonTap.Request) {
        guard let login = loginText, !login.isEmpty,
              let password = passwordText, !password.isEmpty else {
            presenter?.presentAlert(response: LogInRegistrFlow.AlertInfo.Response(alertAt: .someFieldIsEmpty))
            return
        }

        if userPreferences.isRegistered && userPreferences.username == login {
            if let savedPassword = keychain.password, savedPassword == password {
                presenter?.presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response())
            } else {
                presenter?.presentAlert(response: LogInRegistrFlow.AlertInfo.Response(alertAt: .invalidPassword))
            }
        } else {
            // Регистрация
            userPreferences.isRegistered = true
            userPreferences.username = login
            keychain.username = login
            keychain.password = password
            presenter?.presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response())
        }
    }

    func logOut() {
        userPreferences.isRegistered = false
        userPreferences.username = nil
        keychain.username = nil
        keychain.password = nil
        userPreferences.hasLoggedInOnce = false
    }

}
