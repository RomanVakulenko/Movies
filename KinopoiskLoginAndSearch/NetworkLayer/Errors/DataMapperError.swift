//
//  DataMapperError.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

enum DataMapperError: Error, CustomStringConvertible {
    case failAtMapping

    var description: String {
        switch self {
        ///Ошибка от сервера (HTTP-статус 4xx) или ошибка при парсинге данных.
        case .failAtMapping:
            return """
                   Не могу обновить данные.
                   Что-то пошло не так
                   """
        }
    }
}
