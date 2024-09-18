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
            
        case .failAtMapping:
            return """
                   Can not update.
                   Something is wrong
                   """
        }
    }
}
