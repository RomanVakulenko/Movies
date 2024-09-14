//
//  OneEmailDetailsWorker.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import Foundation

protocol OneEmailDetailsWorkingLogic {
    func getMail(byUIDL uidl: String,
                 completion: @escaping (Result<EmailMessageModel, OneEmailDetailsModel.Errors>) -> Void)
    func createFolder(name: String, completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void)
    func moveMail(_ mailUIDL: String, toFolder folderName: String, completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void)
    func addMail(_ mailData: EmailMessageModel, toFolder folderName: String, completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void)
    func deleteMail(_ mailUIDL: String, completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void)
    func updateIsRead(id: String, isRead: Bool, completion: @escaping (Result<EmailMessageModel, Error>) -> Void)
}

final class OneEmailDetailsWorker: OneEmailDetailsWorkingLogic {

    enum Constants {
        static let amountOfMailsAtPage = 10
    }
    // MARK: - Public properties

    // MARK: - Private properties
    private let mailManager = DIManager.shared.container.resolve(EmailManagerProtocol.self)!

    // MARK: - Public methods

    func getMail(byUIDL uidl: String,
                 completion: @escaping (Result<EmailMessageModel, OneEmailDetailsModel.Errors>) -> Void) {

        mailManager.getMail(byUIDL: uidl) { result in
            switch result {
            case .success(let oneEmailMessage):
                completion(.success(oneEmailMessage))

            case .failure(_):
                completion(.failure(.cantFetchOneEmail))
            }
        }
    }

    func createFolder(name: String, 
                      completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void) {
        Log.i("Creating folder: \(name)")

        mailManager.createFolder(name: name) { result in
            switch result {
            case .success():
                completion(.success(Void()))

            case .failure(_):
                completion(.failure(.errorAtCreatingFolder))
            }
        }
    }

    func moveMail(_ mailUIDL: String, 
                  toFolder folderName: String,
                  completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void) {
        Log.i("Moving mail to folder: \(folderName)")

        mailManager.moveMail(mailUIDL, toFolder: folderName) { result in
            switch result {
            case .success():
                completion(.success(Void()))

            case .failure(_):
                completion(.failure(.errorAtMovingToFolder))
            }
        }
    }

    func addMail(_ mailData: EmailMessageModel, 
                 toFolder folderName: String,
                 completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void) {

        Log.i("Adding mail to folder: \(folderName)")
        mailManager.addMail(mailData, toFolder: folderName) { result in
            switch result {
            case .success():
                completion(.success(Void()))

            case .failure(_):
                completion(.failure(.errorAtAddingToFolder))
            }
        }
    }

    func deleteMail(_ mailUIDL: String, completion: @escaping (Result<Void, OneEmailDetailsModel.Errors>) -> Void) {
        Log.i("Deleting mail by mailUIDL: \(mailUIDL)")

        mailManager.deleteMail(mailUIDL) { result in
            switch result {
            case .success():
                completion(.success(Void()))

            case .failure(_):
                completion(.failure(.errorAtDeleting))
            }
        }
    }

    func updateIsRead(id: String, isRead: Bool, completion: @escaping (Result<EmailMessageModel, Error>) -> Void) {
        mailManager.updateIsRead(id: id,
                                 isRead: isRead,
                                 folder: .input,
                                 completion: completion)
    }

}
