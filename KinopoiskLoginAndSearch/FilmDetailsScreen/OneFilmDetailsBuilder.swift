//
//  OneEmailDetailsBuilder.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import UIKit

protocol OneEmailDetailsBuilderProtocol: AnyObject {
    func getControllerWith(id: String, 
                           messageTypeFromSideMenu: TabBarManager.MessageType) -> UIViewController
}

final class OneEmailDetailsBuilder: OneEmailDetailsBuilderProtocol {

    func getControllerWith(id: String, 
                           messageTypeFromSideMenu: TabBarManager.MessageType) -> UIViewController {
        let viewController = OneEmailDetailsController()
        let interactor = OneEmailDetailsInteractor(mailUIDL: id, 
                                                   messageTypeFromSideMenu: messageTypeFromSideMenu)
        let presenter = OneEmailDetailsPresenter()
        let worker = OneEmailDetailsWorker()
        let router = OneEmailDetailsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        return viewController
    }
}
