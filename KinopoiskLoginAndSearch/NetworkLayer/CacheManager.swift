//
//  CacheManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import Foundation


import Foundation

protocol CacheManagerProtocol {
    func isObjectExist(forKey key: String, completion: @escaping (Bool) -> Void)
    func getObject(forKey key: String, completion: @escaping (String?) -> Void)
    func setObject(_ obj: String, forKey key: String, completion: @escaping (Bool) -> Void)
    func removeObject(forKey key: String, completion: @escaping (Bool) -> Void)
}

final class CacheManager: CacheManagerProtocol {
    private let fileManager = FileManager.default
    private let coreDataManager: LocalStorageManagerProtocol

    init(coreDataManager: LocalStorageManagerProtocol) {
        self.coreDataManager = coreDataManager
    }

    func isObjectExist(forKey key: String, completion: @escaping (Bool) -> Void) {
        coreDataManager.fetchURLs { result in
            switch result {
            case .success(let dictOfURLs):
                completion(dictOfURLs[key] != nil)
            case .failure(let error):
                print("Failed to fetch URLs from Core Data: \(error)")
                completion(false)
            }
        }
    }
    //Обычно возвращают Data по ключу, но для реализации кеша здесь по ключу(stringForLoadAvatarForNet) берем значение(stringToGetFileFromTemp) - Object для нас
    func getObject(forKey key: String, completion: @escaping (String?) -> Void) {
        coreDataManager.fetchURLs { result in
            switch result {
            case .success(let dictOfURLs):
                completion(dictOfURLs[key])
            case .failure(let error):
                print("Failed to fetch URLs from Core Data: \(error)")
                completion( String() )
            }
        }
    }

    //Обычно сохраняют Data по ключу, но для реализации кеша здесь по ключу(stringForLoadAvatarForNet) храним значение(stringToGetFileFromTemp)
    func setObject(_ value: String, forKey key: String, completion: @escaping (Bool) -> Void) {

        coreDataManager.saveURLs([key: value]) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Failed to save URLs to Core Data: \(error)")
                completion(false)
            }
        }
    }

    func removeObject(forKey key: String, completion: @escaping (Bool) -> Void) {
        coreDataManager.fetchURLs { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let urls):
                let fileURL = URL(fileURLWithPath: urls[key] ?? "")
                if fileManager.fileExists(atPath: urls[key] ?? "") {
                    do {
                        try fileManager.removeItem(at: fileURL)

                        // Обновляем словарь в Core Data, перезаписывая
                        coreDataManager.saveURLs([key: ""]) { result in
                            switch result {
                            case .success:
                                completion(true)
                            case .failure(let error):
                                print("Failed to remove value to Core Data: \(error)")
                                completion(false)
                            }
                        }
                    } catch {
                        print("Failed to remove value from file: \(error)")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("Failed to fetch URLs from Core Data: \(error)")
                completion(false)
            }
        }
    }
}
