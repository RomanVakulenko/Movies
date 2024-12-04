//
//  LogInRegistrTest.swift
//  KinopoiskLoginAndSearchTests
//
//  Created by Roman Vakulenko on 01.11.2024.
//

import XCTest
@testable import KinopoiskLoginAndSearch


final class LogInRegistrTest: XCTestCase {

    var sut: LogInRegistrController?

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = LogInRegistrBuilder().getController() as? LogInRegistrController
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testThatScreenAssemblesCorrectly() {
        guard let viewController = sut else {
            XCTFail("Configuring viewController fails")
            return
        }

        XCTAssertNotNil(sut, "loginViewController is nil")

        XCTAssertNotNil(viewController.interactor, "viewController.interactor is nil")
        XCTAssertTrue(viewController.interactor is LogInRegistrInteractor, "interactor is not LogInRegistrInteractor")

        XCTAssertNotNil(viewController.router, "viewController.router is nil")
        XCTAssertTrue(viewController.router is LogInRegistrRouter, "router is not LogInRegistrInteractor")


        guard let interactor = viewController.interactor as? LogInRegistrInteractor else {
            XCTFail("Cannot assign viewController.interactor as LogInRegistrInteractor")
            return
        }

        XCTAssertNotNil(interactor.presenter, "interactor.presenter is nil")
        XCTAssertTrue(interactor.presenter is LogInRegistrPresenter, "presenter is not LogInRegistrPresentationLogic")

        guard let presenter = interactor.presenter as? LogInRegistrPresenter else {
            XCTFail("Cannot assign interactor.presenter as LogInRegistrPresenter")
            return
        }

        XCTAssertNotNil(presenter.viewController, "presenter.viewController is nil")
        XCTAssertTrue(presenter.viewController is LogInRegistrController, "viewController is not LogInRegistrController")

        guard let router = viewController.router as? LogInRegistrRouter else {
            XCTFail("Cannot assign viewController.router as LogInRegistrRouter")
            return
        }

        XCTAssertNotNil(router.dataStore, "dataStore is nil")
        XCTAssertTrue(router.dataStore is LogInRegistrInteractor, "dataStore is not LogInRegistrInteractor")

        XCTAssertNotNil(router.viewController, "router.viewController is nil")
        XCTAssertTrue(router.viewController == viewController, "viewController is not LogInRegistrController")

    }
}
