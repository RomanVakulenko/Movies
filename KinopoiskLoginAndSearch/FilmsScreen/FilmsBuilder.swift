//
//  FilmsBuilder.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol FilmsBuilderProtocol: AnyObject {
    func getController(delegate: FilmsDelegate?) -> UIViewController
}


@available(iOS 13.0, *)
final class FilmsBuilder: FilmsBuilderProtocol {

    func getController(delegate: FilmsDelegate?) -> UIViewController {
        let viewController = FilmsController(delegate: delegate)

        let coreDataManager = StorageDataManager()
        //когда загружаем картинки из сети по film.posterUrlPreview, то сохраняем картинки в FileManager, а при следующей попытке загрузить картинки обращаемся к кешМенеджеру(он спрашивает у БД есть ли в ней путь до сохраненной data, если нет, то загружаем из сети и сохраняем в FileManager)
        let networkManager = NetworkManager()
        let worker = FilmsWorker(networkManager: networkManager)
        let interactor = FilmsInteractor()
        let presenter = FilmsPresenter()
        let router = FilmsRouter()

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
