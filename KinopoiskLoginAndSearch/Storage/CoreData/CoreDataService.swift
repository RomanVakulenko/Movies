//
//  CoreDataService.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 18.09.2024.
//


import Foundation
import CoreData
import UIKit

protocol LocalStorageServiceProtocol {
    func isContextEmpty(completion: @escaping (Bool) -> Void)
    func saveURLs(_ urls: [String: String], completion: @escaping (Result<Void, Error>) -> Void)
    func fetchURLs(completion: @escaping (Result<[String: String], Error>) -> Void)
}

final class CoreDataService: LocalStorageServiceProtocol {

    private let persistentContainer: NSPersistentContainer
    private let queue = DispatchQueue(label: "com.coreDataService.queue", attributes: .concurrent)

    init(container: NSPersistentContainer = NSPersistentContainer(name: "KinopoiskLoginAndSearch")) {
        self.persistentContainer = container
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveContext),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc func saveContext() {
        let context = persistentContainer.viewContext
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    func isContextEmpty(completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            let fetchRequest: NSFetchRequest<URLsExternalAndInternal> = URLsExternalAndInternal.fetchRequest()
            fetchRequest.fetchLimit = 1

            do {
                let count = try context.count(for: fetchRequest)
                completion(count == 0)
            } catch {
                completion(false)
            }
        }
    }


    func saveURLs(_ urls: [String : String], completion: @escaping (Result<Void, Error>) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<URLsExternalAndInternal> = URLsExternalAndInternal.fetchRequest()
            if let existingURLs = try? context.fetch(fetchRequest) {
                for urlObject in existingURLs {
                    context.delete(urlObject)
                }
            }
            for (stringForLoadAvatarForNet, stringToGetFileFromTemp) in urls {
                let urlEntity = URLsExternalAndInternal(context: context)
                urlEntity.stringForLoadAvatarForNet = stringForLoadAvatarForNet
                urlEntity.stringToGetFileFromTemp = stringToGetFileFromTemp
            }

            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }



    func fetchURLs(completion: @escaping (Result<[String : String], Error>) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<URLsExternalAndInternal> = URLsExternalAndInternal.fetchRequest()
            
            do {
                let urlEntities = try context.fetch(fetchRequest)
                var urlsDictionary = [String : String]()
                
                for urlEntity in urlEntities {
                    if let stringForLoadAvatarForNet = urlEntity.stringForLoadAvatarForNet,
                       let stringToGetFileFromTemp = urlEntity.stringToGetFileFromTemp {
                        urlsDictionary[stringForLoadAvatarForNet] = stringToGetFileFromTemp
                    }
                }
                completion(.success(urlsDictionary))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}
