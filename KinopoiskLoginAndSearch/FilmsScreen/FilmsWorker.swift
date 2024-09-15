//
//  FilmsWorker.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol FilmsWorkingLogic {
//    func loadFilmsFromNetwork(completion: @escaping (Result<TaskList, Error>) -> Void)
//    func searchContacts(by query: String,
//                        completion: @escaping (Result<[String], OneContactDetailsModel.Errors>) -> Void)
}


final class FilmsWorker: FilmsWorkingLogic {

    // MARK: - Private properties
    private let networkManager: NetworkManagerProtocol

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

//    func loadFilmsFromNetwork(completion: @escaping (Result<TaskList, Error>) -> Void) {
//        networkManager.loadData { [weak self] result in
//            switch result {
//            case .success(let taskList):
//                completion(.success(taskList))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//
//    func searchFilms(by query: String,
//                        completion: @escaping (Result<[String], OneContactDetailsModel.Errors>) -> Void) {
//        contactManager.searchContacts(by: query) { result in
//            switch result {
//            case .success(let foundContacts):
//                let filteredEmails = foundContacts.map { $0.email.lowercased() }
//                completion(.success(filteredEmails))
//
//            case .failure(_):
//                completion(.failure(.cantSearchContacts))
//            }
//        }
//    }
}

