//
//  NetworkManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

typealias NetworkManagerCompletion = (Result<TaskList, NetworkManagerErrors>) -> Void

protocol NetworkManagerProtocol: AnyObject {
   func loadData(completion: @escaping NetworkManagerCompletion)
}


final class NetworkManager {

    // MARK: - Private properties
    private let networkService: NetworkServiceProtocol
    private let mapper: DataMapperProtocol

    // MARK: - Init
    init(networkService: NetworkServiceProtocol, mapper: DataMapperProtocol) {
        self.networkService = networkService
        self.mapper = mapper
    }

    // MARK: - Public methods
    private func createURLRequest(with url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}


// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {

    func loadData(completion: @escaping NetworkManagerCompletion) {
        guard let url = StandardEndpoint().url else {
            print("Не удалось создать url")
            completion(.failure(.invalidURL))
            return
        }
        guard let urlRequest = createURLRequest(with: url) else {
            print("Не удалось создать urlRequest")
            completion(.failure(.invalidRequest))
            return
        }

        networkService.requestDataWith(urlRequest) { [weak self] result in
            switch result {
            case .success(let data):
                self?.mapper.decode(from: data, toStruct: DTOTaskList.self) { decodeResult in
                    switch decodeResult {
                    case .success(let decodedTasks):
                        // Создаем бизнес-модель из декодированных задач
                        let businessModel = TaskList(from: decodedTasks)
                        completion(.success(businessModel)) // Возвращаем бизнес-модель
                    case .failure:
                        completion(.failure(.dataMapperError(error: .failAtMapping)))
                    }
                }
            case .failure(let error):
                completion(.failure(.netServiceError(error: error)))
            }
        }
    }
}


