//
//  LogInRegistrInteractor.swift
//  SGTS
//
//  Created by Roman Vakulenko on 03.04.2024.
//

import Foundation

protocol LogInRegistrBusinessLogic {
    func onDidLoadViews(request: LogInRegistrFlow.OnDidLoadViews.Request)
    func enterButtonTapped(request: LogInRegistrFlow.OnEnterButtonTap.Request)
}

protocol LogInRegistrDataStore: AnyObject {}


final class LogInRegistrInteractor: LogInRegistrBusinessLogic, LogInRegistrDataStore {

    // MARK: - Public properties
    var presenter: LogInRegistrPresentationLogic?
    var worker: LogInRegistrWorkingLogic?

    // MARK: - Lifecycle
    deinit {}

    // MARK: - Public methods

    func onDidLoadViews(request: LogInRegistrFlow.OnDidLoadViews.Request) {
        presenter?.presentUpdate(response: LogInRegistrFlow.Update.Response())
    }

    func enterButtonTapped(request: LogInRegistrFlow.OnEnterButtonTap.Request) {
        presenter?.presentRouteToFilmsScreen(response: LogInRegistrFlow.RoutePayload.Response())
    }

}
