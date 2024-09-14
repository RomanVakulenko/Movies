//
//  KeychainKino.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol ApplicationKeychain {
    var username: String? { get set }
    var password: String? { get set }
    var token: String? { get set }
}

protocol KeyValueStorage {
    func string(forKey key: String) -> String?
    func data(forKey key: String) -> Data?
    func bool(forKey key: String) -> Bool?

    func set(_ value: String, key: String)
    func set(_ value: Data, key: String)
    func set(_ value: Bool, key: String)

    func removeValue(forKey key: String)
    func removeAll()
}


final class KeychainKino {

    private enum Keys {
        static let username = "kinopoisk_username"
        static let password = "kinopoisk_password"
        static let token = "kinopoisk_token"
    }

    let storage: KeyValueStorage
    static let shared: KeychainKino = .init()

    private init(storage: KeyValueStorage = KeychainWrapper()) {
        self.storage = storage
    }

}

// MARK: - ApplicationKeychain
extension KeychainKino: ApplicationKeychain {

    var username: String? {
        get {
            return storage.string(forKey: Keys.username)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.username)
            } else {
                storage.removeValue(forKey: Keys.username)
            }
        }
    }

    var password: String? {
        get {
            return storage.string(forKey: Keys.password)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.password)
            } else {
                storage.removeValue(forKey: Keys.password)
            }
        }
    }

    var token: String? {
        get {
            return storage.string(forKey: Keys.token)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.token)
            } else {
                storage.removeValue(forKey: Keys.token)
            }
        }
    }

}
