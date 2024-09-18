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
        static let isRegistered = "kinopoisk_is_registered"
        static let hasLoggedInOnce = "kinopoisk_has_logged_in_once"
        static let avatarPaths = "kinopoisk_avatar_paths"
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

    var isRegistered: Bool {
        get {
            return storage.bool(forKey: Keys.isRegistered) ?? false
        }
        set {
            storage.set(newValue, key: Keys.isRegistered)
        }
    }

    var hasLoggedInOnce: Bool {
        get {
            return storage.bool(forKey: Keys.hasLoggedInOnce) ?? false
        }
        set {
            storage.set(newValue, key: Keys.hasLoggedInOnce)
        }
    }

    var avatarPaths: [String]? {
        get {
            return storage.array(forKey: Keys.avatarPaths)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.avatarPaths)
            } else {
                storage.removeValue(forKey: Keys.avatarPaths)
            }
        }
    }
}
