//
//  RealmDataService.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 04.11.2024.
//

import Foundation
import RealmSwift
import UIKit


final class RealmDataService: LocalStorageServiceProtocol {
    static let shared: LocalStorageServiceProtocol = RealmDataService()
    private let queue = DispatchQueue(label: "com.realmService.queue", attributes: .concurrent)

    private init() {
        configureRealm()
    }

    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Пример миграции: Если добавляется новое поле, его нужно инициализировать
                }
            },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                // Сжимаем базу данных при запуске, если более 50% пространства не используется
                let fiftyMB = 50 * 1024 * 1024
                return (totalBytes > fiftyMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5 //База данных занимает больше 50 MB  и используется менее 50% от всего объема базы данных.
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }

    func saveURLs(_ urls: [String : String], completion: @escaping (Result<Void, Error>) -> Void) {
        //        Log.i("Creating folder with name: \(name)")
        queue.async(flags: .barrier) {
            Realm.asyncOpen { result in
                switch result {
                case .success(let realm):
                    do {
                        try realm.write {
                            // Delete existing URLs
                            let existingURLs = realm.objects(URLRealmModel.self)
                            realm.delete(existingURLs)

                            // Add new URLs
                            for (stringForLoadAvatarForNet, stringToGetFileFromTemp) in urls {
                                let urlEntity = URLRealmModel()
                                urlEntity.stringForLoadAvatarForNet = stringForLoadAvatarForNet
                                urlEntity.stringToGetFileFromTemp = stringToGetFileFromTemp
                                realm.add(urlEntity)
                            }
                        }
                        //                        Log.i("Folder \(name) created successfully")
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } catch {
                        //                        Log.e("Failed to create folder \(name): \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    //                    Log.e("Failed to open Realm for creating folder \(name): \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }

            }
        }
    }

    func fetchURLs(completion: @escaping (Result<[String: String], Error>) -> Void) {
        queue.async {
            Realm.asyncOpen { result in
                switch result {
                case .success(let realm):
                    let urlEntities = realm.objects(URLRealmModel.self)
                    var urlsDictionary = [String: String]()

                    for urlEntity in urlEntities {
                        urlsDictionary[urlEntity.stringForLoadAvatarForNet] = urlEntity.stringToGetFileFromTemp
                    }
                    //                        Log.i("Fetched (emails.count) emails")
                    DispatchQueue.main.async {
                        completion(.success(urlsDictionary))
                    }
                case .failure(let error):
//                    Log.e("Failed to fetch emails: (error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }

            }
        }
    }

    func isContextEmpty(completion: @escaping (Bool) -> Void) {
        ()
    }
}
