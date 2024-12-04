//
//  KeyсhainWrapper.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import Security

// MARK: - KeychainWrapper
final class KeychainWrapper {
    let service: String

    init(service: String = "com.kinopoisk") {
        self.service = service
    }
}

// MARK: - KeychainError
enum KeychainError: Error {
    case accessError(OSStatus)
    case invalidData
    case transformError
}

// MARK: - KeyValueStorage
extension KeychainWrapper: KeyValueStorage {
    func set(_ value: [String], key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            set(data, key: key) // Используем правильный метод для сохранения Data
        } catch {
            print("Error setting array in Keychain: \(error)")
        }
    }

    func array(forKey key: String) -> [String]? {
        do {
            if let data = data(forKey: key) { // Используем getData для получения Data
                let array = try JSONDecoder().decode([String].self, from: data)
                return array
            }
        } catch {
            print("Error getting array from Keychain: \(error)")
        }
        return nil
    }

    func string(forKey key: String) -> String? {
        guard let data = data(forKey: key) else {
            return nil
        }

        guard let value = String(data: data, encoding: .utf8) else {
            assertionFailure("Keychain error: \(KeychainError.invalidData)")
            return nil
        }

        return value
    }

    func data(forKey key: String) -> Data? {
        let query = KeychainQueryFactory.makeQuery(forService: service, key: key)
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == noErr else {
            assertionFailure("Keychain access error: \(KeychainError.accessError(status))")
            return nil
        }

        if let resultDictionary = result as? [String: Any], let data = resultDictionary[kSecValueData as String] as? Data {
            return data
        }

        return nil
    }

    func bool(forKey key: String) -> Bool? {
        guard let data = data(forKey: key) else {
            return nil
        }

        guard let value = (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: data)) as? Bool else {
            assertionFailure("Keychain unable to transform bool")
            return nil
        }


        return value
    }

    func set(_ value: String, key: String) {
        // Если нужна допБезопасность - хешируем пароль ДО сохранения
//        guard let hashedValue = Crypto.hash(message: value) else {
//            assertionFailure("Unable to hash password")
//            return
//        }

        guard let data = value.data(using: .utf8) else {
            assertionFailure("Unable to set data in keychain: \(KeychainError.invalidData)")
            return
        }

        set(data, key: key)
    }
    //
    func set(_ value: Data, key: String) {
        let query = KeychainQueryFactory.makeQuery(forService: service, key: key, value: value)

        // Удаляем существующие данные
        SecItemDelete(query as CFDictionary)

        ///Adds one or more items to a keychain.
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != noErr {
            assertionFailure("Keychain access error setting value \(value): \(KeychainError.accessError(status))")
        }
    }

    func set(_ value: Bool, key: String) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
            assertionFailure("Keychain unable to transform bool")
            return
        }

        set(data, key: key)
    }

    func removeValue(forKey key: String) {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = key
        query[kSecAttrService as String] = service

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecItemNotFound && status != errSecSuccess {
            assertionFailure("Unable to delete value for key \(key): \(KeychainError.accessError(status))")
        }
    }
//
//    func removeAll() {
//        var query: [String: Any] = [:]
//        query[kSecClass as String] = kSecClassGenericPassword
//        query[kSecAttrService as String] = service
//
//        let status = SecItemDelete(query as CFDictionary)
//
//        if status != errSecItemNotFound && status != errSecSuccess {
//            assertionFailure("Unable to delete all values in Keychain: \(KeychainError.accessError(status))")
//        }
//    }
}
