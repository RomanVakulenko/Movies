//
//  UserPreferences.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

final class UserPreferences {

    private enum Keys {
        static let rememberMe = "kinopoisk_remember"
        static let userName = "kinopoisk_username"
    }

    let storage: KeyValueStorage
    static let shared: UserPreferences = .init()

    private init(storage: KeyValueStorage = UserDefaultsWrapper()) {
        self.storage = storage
    }

    var isUsernameStored: Bool? {
        get {
            return storage.bool(forKey: Keys.rememberMe)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.rememberMe)
            } else {
                storage.removeValue(forKey: Keys.rememberMe)
            }

        }
    }

    var username: String? {
        get {
            return storage.string(forKey: Keys.userName)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.userName)
            } else {
                storage.removeValue(forKey: Keys.userName)
            }

        }
    }
}
