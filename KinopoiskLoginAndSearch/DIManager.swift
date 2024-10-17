//
//  DIManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 25.09.2024.
//

import Swinject

final class DIManager {

    // MARK: - Public properties
    static let shared = DIManager()
    let container: Container

    // MARK: - Private properties
    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {

        container.register(NetworkServiceProtocol.self) { _ in
            NetworkService()
        }.inObjectScope(.container)

        container.register(DataMapperProtocol.self) { _ in
            DataMapper()
        }.inObjectScope(.container)
        
        container.register(CacheManagerProtocol.self) { _ in
            CacheManager()
        }.inObjectScope(.container)

        container.register(NetworkManager.self) { _ in
            NetworkManager()
        }.inObjectScope(.graph) //Если объект запрашивается из другого объекта, который тоже создается в этом графе, будет возвращен тот же экземпляр.
        container.register(LocalStorageManagerProtocol.self) { _ in
            StorageDataManager.shared
        }.inObjectScope(.container)
        container.register(FileManager.self) { _ in
            FileManager.default
        }.inObjectScope(.container)
    }
}
