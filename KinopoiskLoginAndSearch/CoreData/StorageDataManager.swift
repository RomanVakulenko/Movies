//
//  StorageDataManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 18.09.2024.
//

import CoreData
import UIKit

import Foundation

protocol LocalStorageManagerProtocol {
    func fetchURLs(completion: @escaping (Result<[String: String], Error>) -> Void)
    func isContextEmpty(completion: @escaping (Bool) -> Void)
    func saveURLs(_ urls: [String: String], completion: @escaping (Result<Void, Error>) -> Void)
}


final class StorageDataManager: LocalStorageManagerProtocol {
    static let shared = StorageDataManager()
    private var localStorageService: LocalStorageServiceProtocol = CoreDataService.shared

    func fetchURLs(completion: @escaping (Result<[String: String], Error>) -> Void) {
        localStorageService.fetchURLs { result in
            switch result {
            case .success(let urls):
                completion(.success(urls))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func isContextEmpty(completion: @escaping (Bool) -> Void) {
        localStorageService.isContextEmpty { isEmpty in
            completion(isEmpty)
        }
    }

    func saveURLs(_ urls: [String: String], completion: @escaping (Result<Void, Error>) -> Void) {
        localStorageService.saveURLs(urls) { result in
            completion(result)
        }
    }
}
