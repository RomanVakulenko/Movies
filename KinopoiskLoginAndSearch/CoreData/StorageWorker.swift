////
////  StorageWorker.swift
////  KinopoiskLoginAndSearch
////
////  Created by Roman Vakulenko on 18.09.2024.
////
//
//import Foundation
//

//можно использовать один воркер общий для двух экранов, т.к. суть схожа
//protocol StorageWorkerProtocol {
//    func fetchURLsFromDataBase(completion: @escaping (Result<[String: String], Error>) -> Void)
//    func saveURLs(_ urls: [String: String], completion: @escaping (Result<Void, Error>) -> Void)
//    func isDBEmpty(completion: @escaping (Bool) -> Void)
//}
//
//final class StorageWorker: StorageWorkerProtocol {
//    // MARK: - Private properties
//    private let coreDataManager: LocalStorageManagerProtocol
//
//    // MARK: - Init
//    init(coreDataManager: LocalStorageManagerProtocol) {
//        self.coreDataManager = coreDataManager
//    }
//
//    // MARK: - Public methods
//    func isDBEmpty(completion: @escaping (Bool) -> Void) {
//        coreDataManager.isContextEmpty { isEmpty in
//            completion(isEmpty)
//        }
//    }
//
//    func fetchURLsFromDataBase(completion: @escaping (Result<[String: String], Error>) -> Void) {
//        coreDataManager.fetchURLs { result in
//            switch result {
//            case .success(let urls):
//                completion(.success(urls))
//            case .failure(let error):
//                print("Failed to fetch URLs from CoreData: \(error)")
//                completion(.failure(error))
//            }
//        }
//    }
//
//    func saveURLs(_ urls: [String: String], completion: @escaping (Result<Void, Error>) -> Void) {
//        coreDataManager.saveURLs(urls) { result in
//            switch result {
//            case .success:
//                completion(.success(()))
//            case .failure(let error):
//                print("Failed to save URLs to CoreData: \(error)")
//                completion(.failure(error))
//            }
//        }
//    }
//}
