//
//  NetworkManagerErrors.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

enum NetworkManagerErrors: Error, CustomStringConvertible {
    case netServiceError(error: NetServiceError)
    case dataMapperError(error: DataMapperError)
    case invalidURL
    case invalidRequest
    case noData


    var description: String {
        switch self {
        case .netServiceError(let error):
            return "Network service error: \(error.description)"
        case .dataMapperError(let error):
            return "Data mapper error: \(error.description)"
        case .invalidURL:
            return "The provided URL is invalid."
        case .invalidRequest:
            return "The URL request could not be created."
        case .noData:
            return "No data was returned from the server."
        }
    }
}
