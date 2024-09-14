//
//  AddressBookWorker.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import Foundation

protocol AddressBookWorkingLogic {
    func getAllContacts(completion: @escaping (Result<[ContactListItem], OneContactDetailsModel.Errors>) -> Void)
    func searchContacts(by query: String,
                        completion: @escaping (Result<[String], OneContactDetailsModel.Errors>) -> Void)
}


final class AddressBookWorker: AddressBookWorkingLogic {

    // MARK: - Private properties

    private let contactManager = ContactManager.shared.self

    // MARK: - Public methods

    func getAllContacts(completion: @escaping (Result<[ContactListItem], OneContactDetailsModel.Errors>) -> Void) {
        contactManager.getAllContacts() { result in
            switch result {
            case .success(let arrayOfContacts):
                completion(.success(arrayOfContacts))

            case .failure(_):
                completion(.failure(.cantFetchAllContacts))
            }
        }
    }

    func searchContacts(by query: String,
                        completion: @escaping (Result<[String], OneContactDetailsModel.Errors>) -> Void) {
        contactManager.searchContacts(by: query) { result in
            switch result {
            case .success(let foundContacts):
                let filteredEmails = foundContacts.map { $0.email.lowercased() }
                completion(.success(filteredEmails))

            case .failure(_):
                completion(.failure(.cantSearchContacts))
            }
        }
    }
}
