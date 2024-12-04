//
//  NetworkService.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol NetworkServiceProtocol: AnyObject {
    func requestDataWith(_ urlRequest: URLRequest) async throws -> Data
}


final class NetworkService { }

//возвращает DTO

// MARK: - Extensions
extension NetworkService: NetworkServiceProtocol {
    func requestDataWith(_ urlRequest: URLRequest) async throws -> Data {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30

        let session = URLSession(configuration: configuration)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetServiceError.serverError
        }

        let statusCode = httpResponse.statusCode

        switch statusCode {
        case 401:
            throw NetServiceError.invalidToken
        case 402:
            throw NetServiceError.requestLimitExceeded
        case 404:
            throw NetServiceError.movieNotFound
        case 429:
            throw NetServiceError.tooManyRequests
        case 400...499:
            throw NetServiceError.badStatusCode(statusCode)
        case 500...599:
            throw NetServiceError.serverError
        default:
            break
        }

        return data
    }
}



//на комплишенах
//typealias NetworkServiceCompletion = (Result<Data, NetServiceError>) -> Void
//
//protocol NetworkServiceProtocol: AnyObject {
//    func requestDataWith(_ urlRequest: URLRequest,
//                         completion: @escaping NetworkServiceCompletion)
//}
//
//
//final class NetworkService { }
//
////возвращает DTO
//
//// MARK: - Extensions
//extension NetworkService: NetworkServiceProtocol {
//
//    func requestDataWith(_ urlRequest: URLRequest, completion: @escaping NetworkServiceCompletion) {
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 10
//        configuration.timeoutIntervalForResource = 30
//
//        let session = URLSession(configuration: configuration)
//
//        session.dataTask(with: urlRequest) { data, response, error in
//            if let error = error as NSError? {
//                let netError: NetServiceError
//                if error.domain == NSURLErrorDomain || error.code == NSURLErrorTimedOut {
//                    netError = .badInternetConnection
//                } else {
//                    netError = .serverError
//                }
//                DispatchQueue.main.async { completion(.failure(netError)) }
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                let statusCode = httpResponse.statusCode
//
//                switch statusCode {
//                case 401:
//                    DispatchQueue.main.async { completion(.failure(.invalidToken)) }
//                    return
//                case 402:
//                    DispatchQueue.main.async { completion(.failure(.requestLimitExceeded)) }
//                    return
//                case 404:
//                    DispatchQueue.main.async { completion(.failure(.movieNotFound)) }
//                    return
//                case 429:
//                    DispatchQueue.main.async { completion(.failure(.tooManyRequests)) }
//                    return
//                case 400...499:
//                    DispatchQueue.main.async { completion(.failure(.badStatusCode(statusCode))) }
//                    return
//                case 500...599:
//                    DispatchQueue.main.async { completion(.failure(.serverError)) }
//                    return
//                default:
//                    break
//                }
//            }
//
//            guard let data = data else {
//                DispatchQueue.main.async { completion(.failure(.noData)) }
//                return
//            }
//
//            DispatchQueue.main.async { completion(.success(data)) }
//        }.resume()
//    }
//}
