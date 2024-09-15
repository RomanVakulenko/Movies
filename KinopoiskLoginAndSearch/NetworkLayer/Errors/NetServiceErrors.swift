//
//  NetServiceErrors.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 15.09.2024.
//

import Foundation


enum NetServiceError: Error, LocalizedError {
    case badInternetConnection
    case badStatusCode(Int)
    case unknownError
    case invalidToken
    case requestLimitExceeded
    case movieNotFound
    case tooManyRequests
    case noData

    var errorDescription: String? {
        switch self {
        case .badInternetConnection:
            return "Unable to update data. Please check your internet connection."
        case .badStatusCode(let statusCode):
            return "Unable to update data. Received status code: \(statusCode)."
        case .unknownError:
            return "An unknown error occurred."
        case .invalidToken:
            return "Error 401: Invalid or missing token."
        case .requestLimitExceeded:
            return "Error 402: Request limit exceeded."
        case .movieNotFound:
            return "Error 404: Movie not found."
        case .tooManyRequests:
            return "Error 429: Too many requests. Please wait and try again."
        case .noData:
            return "No data available."
        }
    }
}
