//
//  NetworkManagerErrors.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

enum NetworkManagerErrors: Error, LocalizedError {
    case netServiceError(NetServiceError)
    case dataMapperError(DataMapperError)
    case invalidURL
    case invalidRequest

    var errorDescription: String? {
        switch self {
        case .netServiceError(let error):
            return "Network service error: \(error.localizedDescription)"
        case .dataMapperError(let error):
            return "Data mapper error: \(error.localizedDescription)"
        case .invalidURL:
            return "The provided URL is invalid."
        case .invalidRequest:
            return "The URL request could not be created."
        }
    }
}
