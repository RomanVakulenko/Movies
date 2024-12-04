//
//  StorageBaseModels.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 04.11.2024.
//

import Foundation
import RealmSwift

class URLRealmModel: Object {
    @Persisted(primaryKey: true) var stringForLoadAvatarForNet: String
    @Persisted var stringToGetFileFromTemp: String
}
