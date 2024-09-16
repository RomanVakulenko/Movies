//
//  CacheManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import Foundation

protocol CacheManagerProtocol {
    func getObject(forKey key: NSString) -> NSData?
    func setObject(_ obj: NSData, forKey key: NSString)
    func removeObject(forKey key: NSString)
}

final class CacheManager: CacheManagerProtocol {
    private let cache = NSCache<NSString, NSData>()

    func getObject(forKey key: NSString) -> NSData? {
        return cache.object(forKey: key)
    }

    func setObject(_ obj: NSData, forKey key: NSString) {
        cache.setObject(obj, forKey: key)
    }

    func removeObject(forKey key: NSString) {
        cache.removeObject(forKey: key)
    }
}
