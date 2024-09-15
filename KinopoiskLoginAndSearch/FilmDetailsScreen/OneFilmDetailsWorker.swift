//
//  OneFilmDetailsWorker.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol OneFilmDetailsWorkingLogic {
    func getImages(filmId: String,
                   completion: @escaping (Result<EmailMessageModel, OneEmailDetailsModel.Errors>) -> Void)
}

final class OneFilmDetailsWorker: OneFilmDetailsWorkingLogic {

   
    // MARK: - Private properties
    private let networkManager: NetworkManagerProtocol

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func getImages(completion: @escaping (Result<TaskList, Error>) -> Void) {
        networkManager.getImages { [weak self] result in
            switch result {
            case .success(let taskList):
                completion(.success(taskList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
