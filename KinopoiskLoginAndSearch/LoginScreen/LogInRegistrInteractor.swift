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
}

protocol LogInRegistrDataStore: AnyObject {}


final class LogInRegistrInteractor: LogInRegistrBusinessLogic, LogInRegistrDataStore {

    // MARK: - Public properties
    var presenter: LogInRegistrPresentationLogic?
    var worker: LogInRegistrWorkingLogic?

    // MARK: - Private properties
    var loginText: String?
    var passwordText: String?

    // MARK: - Lifecycle
    deinit {}

    // MARK: - Public methods

    func onDidLoadViews(request: LogInRegistrFlow.OnDidLoadViews.Request) {
        presenter?.presentUpdate(response: LogInRegistrFlow.Update.Response())
    }

    func useCurrent(loginText: String, passwordText: String) {
        self.loginText = loginText
        self.passwordText = passwordText
    }

    func enterButtonTapped(request: LogInRegistrFlow.OnEnterButtonTap.Request) {
//        worker?.//save or do smth
        presenter?.presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response())
    }

}
