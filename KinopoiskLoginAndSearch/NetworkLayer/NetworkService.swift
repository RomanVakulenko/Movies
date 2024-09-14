//
//  NetworkService.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

typealias NetworkServiceCompletion = (Result<Data, NetServiceError>) -> Void

protocol NetworkServiceProtocol: AnyObject {
    func requestDataWith(_ urlRequest: URLRequest,
                         completion: @escaping NetworkServiceCompletion)
}


final class NetworkService { }

//возвращает DTO

// MARK: - Extensions
extension NetworkService: NetworkServiceProtocol {

    func requestDataWith(_ urlRequest: URLRequest, completion: @escaping NetworkServiceCompletion) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30

        let session = URLSession(configuration: configuration)

        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error as NSError? {
                let netError: NetServiceError
                if error.domain == NSURLErrorDomain || error.code == NSURLErrorTimedOut {
                    netError = .badInternetConnection
                } else {
                    netError = .unknownError
                }
                DispatchQueue.main.async { completion(.failure(netError)) }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if (400...499).contains(statusCode) {
                    DispatchQueue.main.async { completion(.failure(.badStatusCode)) }
                    return
                } else if (500...599).contains(statusCode) {
                    DispatchQueue.main.async { completion(.failure(.badInternetConnection)) }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            DispatchQueue.main.async { completion(.success(data)) }
        }.resume()
    }

}
