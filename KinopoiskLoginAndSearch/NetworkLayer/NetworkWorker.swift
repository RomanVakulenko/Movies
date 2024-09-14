//
//  NetworkWorker.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol FilmsNetworkWorkerProtocol {
    func loadToDosFromNetwork(completion: @escaping (Result<TaskList, Error>) -> Void)
}


final class FilmsNetworkWorker: FilmsNetworkWorkerProtocol {

    // MARK: - Private properties
    private let networkManager: NetworkManagerProtocol

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func loadToDosFromNetwork(completion: @escaping (Result<TaskList, Error>) -> Void) {
        networkManager.loadData { [weak self] result in
            switch result {
            case .success(let taskList):
                completion(.success(taskList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
