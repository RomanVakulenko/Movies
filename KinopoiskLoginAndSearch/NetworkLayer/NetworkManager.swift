//
//  NetworkManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol NetworkManagerProtocol: AnyObject {
    func loadFilms(page: Int, completion: @escaping (Result<Films, NetworkManagerErrors>) -> Void)
    func getFilmDetails(id: Int, completion: @escaping (Result<OneFilm, NetworkManagerErrors>) -> Void)
    func loadFilmImages(id: Int, type: String, page: Int, completion: @escaping (Result<Data, NetworkManagerErrors>) -> Void)

}


final class NetworkManager {
    private let networkService: NetworkServiceProtocol
    private let mapper: DataMapperProtocol
    private let imageCache = NSCache<NSString, NSData>()

    // MARK: - Init

    init(networkService: NetworkServiceProtocol, mapper: DataMapperProtocol) {
        self.networkService = networkService
        self.mapper = mapper
    }

    // MARK: - Private methods

    private func createURLRequest(endpoint: KinopoiskAPI,
                                  method: String = "GET",
                                  body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: endpoint.urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let body = body {
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(KinopoiskAPI.apiKey, forHTTPHeaderField: "X-API-KEY")

        return request
    }

}

// MARK: - Extensions
extension NetworkManager: NetworkManagerProtocol {
    func getFilmDetails(id: Int, 
                        completion: @escaping (Result<OneFilm, NetworkManagerErrors>) -> Void) {
        let endpoint = KinopoiskAPI.filmDetails(id: id)
        guard let request = createURLRequest(endpoint: endpoint) else {
            completion(.failure(.netServiceError(.canNotCreateRequest)))
            return
        }

        networkService.requestDataWith(request) { [weak self] result in
            switch result {
            case .success(let data):
                self?.mapper.decode(from: data, toStruct: OneFilmDTO.self) { decodeResult in
                    switch decodeResult {
                    case .success(let decodedFilmDTO):
                        let film = OneFilm(from: decodedFilmDTO)
                        completion(.success(film))
                    case .failure:
                        completion(.failure(.dataMapperError(.failAtMapping)))
                    }
                }
            case .failure(let error):
                completion(.failure(.netServiceError(error)))
            }
        }
    }


    func loadFilmImages(id: Int, 
                        type: String = "STILL",
                        page: Int,
                        completion: @escaping (Result<Data, NetworkManagerErrors>) -> Void) {
        let cacheKey = "\(id)_\(type)_\(page)" as NSString

        // Проверка в кэше
        if let cachedData = imageCache.object(forKey: cacheKey) {
            completion(.success(cachedData as Data))
            return
        }

        let endpoint = KinopoiskAPI.filmImages(id: id, type: type, page: page)
        guard let request = createURLRequest(endpoint: endpoint) else {
            completion(.failure(.netServiceError(.canNotCreateRequest)))
            return
        }

        networkService.requestDataWith(request) { result in
            switch result {
            case .success(let data):
                self.imageCache.setObject(data as NSData, forKey: cacheKey) // Кэшируем
                completion(.success(data))
            case .failure(let error):
                completion(.failure(.netServiceError(error)))
            }
        }
    }

    // Загрузка списка фильмов постранично
    func loadFilms(page: Int, completion: @escaping (Result<Films, NetworkManagerErrors>) -> Void) {
        let endpoint = KinopoiskAPI.filmsByPage(page: page)

        guard let request = createURLRequest(endpoint: endpoint) else {
            completion(.failure(.netServiceError(.canNotCreateRequest)))
            return
        }
        networkService.requestDataWith(request) { [weak self] result in
            switch result {
            case .success(let data):
                self?.mapper.decode(from: data, toStruct: FilmsDTO.self) { decodeResult in
                    switch decodeResult {
                    case .success(let decodedFilmsDTO):
                        let film = Films(from: decodedFilmsDTO)
                        completion(.success(film))
                    case .failure:
                        completion(.failure(.dataMapperError(.failAtMapping)))
                    }
                }
            case .failure(let error):
                completion(.failure(.netServiceError(error)))
            }
        }
    }
}

