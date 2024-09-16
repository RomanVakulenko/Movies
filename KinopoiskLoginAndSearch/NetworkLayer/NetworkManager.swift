//
//  NetworkManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol NetworkManagerProtocol: AnyObject {
    func loadFilms(page: Int, completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void)

    func getFilmDetails(id: Int, completion: @escaping (Result<DetailsFilm, NetworkManagerErrors>) -> Void)

    func loadFilmImages(id: Int, pageForStills: Int, completion: @escaping (Result<[OneStill], NetworkManagerErrors>) -> Void)
}


final class NetworkManager {

    private let networkService: NetworkServiceProtocol
       private let mapper: DataMapperProtocol
       private let cacheManager: CacheManagerProtocol
       private var isFetching = false
//       private let requestLimitPerSecond = 5
       private var fetchedFilmsCount = 0
       private var amountOfFetchedStills = 0
       private let maxFilms = 400
       private var maxStills = 1

       // MARK: - Init

       init(networkService: NetworkServiceProtocol, 
            mapper: DataMapperProtocol,
            cacheManager: CacheManagerProtocol) {
           self.networkService = networkService
           self.mapper = mapper
           self.cacheManager = cacheManager
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


    private func downloadAndCacheFilmsAvatars(for films: inout [OneFilm],
                                              completion: @escaping (Result<[OneFilm], NetServiceError>) -> Void) {
        let group = DispatchGroup()
        for index in films.indices {
            guard let imageUrl = URL(string: films[index].posterUrlPreview) else { continue }

            if let cachedDataForAvatar = cacheManager.getObject(forKey: imageUrl.absoluteString as NSString) {
                print("Image loaded from cache for film: \(films[index].nameOriginal)")
                films[index].cachedAvatarPath = imageUrl.absoluteString
            } else {
                group.enter()
                networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
                    defer { group.leave() }

                    switch result {
                    case .success(let data):
                        self?.cacheManager.setObject(data as NSData, forKey: imageUrl.absoluteString as NSString)
                        print("Image cached for film: \(films[index].nameOriginal)")
                        films[index].cachedAvatarPath = imageUrl.absoluteString
                    case .failure(let error):
                        print("Failed to load image: \(error)")
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(films))
        }
    }


    private func downloadAndCacheCover(for detailsFilm: inout DetailsFilm,
                                       completion: @escaping (Result<DetailsFilm, NetServiceError>) -> Void) {
        guard let imageUrl = URL(string: detailsFilm.coverUrl ?? "") else {
            completion(.success(detailsFilm))
            return
        }
        // Есть ли в кэше
        if let cachedData = cacheManager.getObject(forKey: imageUrl.absoluteString as NSString) {
            print("Image loaded from cache for detailsFilm: \(detailsFilm.nameOriginal)")
            detailsFilm.coverUrl = imageUrl.absoluteString
            completion(.success(detailsFilm))
        } else {
            networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.cacheManager.setObject(data as NSData, forKey: imageUrl.absoluteString as NSString)
                    print("Image cached for detailsFilm: \(detailsFilm.nameOriginal)")
                    detailsFilm.coverUrl = imageUrl.absoluteString
                    completion(.success(detailsFilm))

                case .failure(let error):
                    print("Failed to load image: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }


    private func downloadAndCacheStills(for stills: inout [OneStill],
                                        completion: @escaping (Result<[OneStill], NetServiceError>) -> Void) {
        let group = DispatchGroup()
        for index in stills.indices {
            guard let imageUrl = URL(string: stills[index].previewURL ?? "") else { continue }

            if let cachedDataForStill = cacheManager.getObject(forKey: imageUrl.absoluteString as NSString) {
                print("Image loaded from cache for previewURL: \(stills[index].previewURL ?? "")")
                stills[index].cachedPreview = imageUrl.absoluteString
            } else {
                group.enter()
                networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
                    defer { group.leave() }

                    switch result {
                    case .success(let data):
                        self?.cacheManager.setObject(data as NSData, forKey: imageUrl.absoluteString as NSString)
                        print("Image cached for previewURL: \(stills[index].previewURL ?? "")")
                        stills[index].cachedPreview = imageUrl.absoluteString
                    case .failure(let error):
                        print("Failed to load image: \(error)")
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(stills))
        }
    }

}

// MARK: - Extensions
extension NetworkManager: NetworkManagerProtocol {

    func loadFilms(page: Int, completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
        guard fetchedFilmsCount < maxFilms else { return }
        let endpoint = KinopoiskAPI.filmsByPage(page: page)

        guard let request = createURLRequest(endpoint: endpoint) else {
            completion(.failure(.netServiceError(.canNotCreateRequest)))
            return
        }

        networkService.requestDataWith(request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.mapper.decode(from: data, toStruct: FilmsDTO.self) { result in
                    switch result {
                    case .success(let decodedFilmsDTO):
                        var films = decodedFilmsDTO.items.map { OneFilm(from: $0) }
                        self.fetchedFilmsCount += films.count

                        self.downloadAndCacheFilmsAvatars(for: &films) { result in
                            switch result {
                            case .success(let filmsWithAvatars):
                                completion(.success(filmsWithAvatars))
                            case .failure(let error):
                                completion(.failure(.netServiceError(error)))
                            }
                        }
                    case .failure:
                        completion(.failure(.dataMapperError(.failAtMapping)))
                    }
                }
            case .failure(let error):
                completion(.failure(.netServiceError(error)))
            }
        }
    }


    func getFilmDetails(id: Int, completion: @escaping (Result<DetailsFilm, NetworkManagerErrors>) -> Void) {
        let endpoint = KinopoiskAPI.filmDetails(filmId: id)
        guard let request = createURLRequest(endpoint: endpoint) else {
            completion(.failure(.netServiceError(.canNotCreateRequest)))
            return
        }

        networkService.requestDataWith(request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.mapper.decode(from: data, toStruct: DetailsFilmDTO.self) { result in
                    switch result {
                    case .success(let decodedDetailsFilmDTO):
                        var film = DetailsFilm(from: decodedDetailsFilmDTO)
                        self.downloadAndCacheCover(for: &film) { result in
                            switch result {
                            case .success(let filmWithCover):
                                completion(.success(filmWithCover))
                            case .failure(let error):
                                completion(.failure(.netServiceError(error)))
                            }
                        }
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
                        pageForStills: Int,
                        completion: @escaping (Result<[OneStill], NetworkManagerErrors>) -> Void) {
        guard !isFetching, amountOfFetchedStills < maxStills else { return }
        isFetching = true

        let endpoint = KinopoiskAPI.filmImages(filmId: id, page: pageForStills)
        guard let request = createURLRequest(endpoint: endpoint) else {
            completion(.failure(.netServiceError(.canNotCreateRequest)))
            isFetching = false
            return
        }

        networkService.requestDataWith(request) { [weak self] result in
            guard let self = self else { return }
            isFetching = false

            switch result {
            case .success(let data):
                self.mapper.decode(from: data, toStruct: StillsDTO.self) { result in
                    switch result {
                    case .success(let decodedStillsDTO):
                        var stills = decodedStillsDTO.items.map { OneStill(from: $0) }
                        self.maxStills = decodedStillsDTO.total
                        
                        self.downloadAndCacheStills(for: &stills){ result in
                            switch result {
                            case .success(let stills):
                                self.amountOfFetchedStills = stills.count
                                completion(.success(stills))
                            case .failure(let error):
                                completion(.failure(.netServiceError(error)))
                            }
                        }
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

