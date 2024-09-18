//
//  NetworkManager.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

protocol NetworkManagerProtocol: AnyObject {
    func loadFilms(page: Int, completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void)
    func downloadAndCacheAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void)

    func getFilmDetails(id: Int, completion: @escaping (Result<DetailsFilm, NetworkManagerErrors>) -> Void)
    func downloadAndCacheCover(for detailsFilm: DetailsFilm,
                                completion: @escaping (Result<DetailsFilm, NetworkManagerErrors>) -> Void)
    func loadFilmStills(filmId: Int,
                        pageForStills: Int,
                        completion: @escaping (Result<[OneStill], NetworkManagerErrors>) -> Void)
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



    private func downloadAndCacheStills(for stills: [OneStill],
                                        completion: @escaping (Result<[OneStill], NetServiceError>) -> Void) {
        var stillsWithPreviews = stills
        let group = DispatchGroup()

        for (index, still) in stills.enumerated() {
            guard let stringForLoadStillFromNet = still.previewURL,
                  let imageUrl = URL(string: stringForLoadStillFromNet) else { continue }

            group.enter()

            cacheManager.isObjectExist(forKey: stringForLoadStillFromNet) { isObjExists in
                if isObjExists {
                    //и записываем stringToGetFileFromTemp в свойство фильма
                    self.cacheManager.getObject(forKey: stringForLoadStillFromNet) { stringToGetFileFromTemp in
                        stillsWithPreviews[index].cachedPreview = stringToGetFileFromTemp
                        group.leave()
                    }
                } else {
                    self.networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
                        guard let self = self else {
                            group.leave()
                            return
                        }

                        switch result {
                        case .success(let data):
                            // Сохраняем файл во временной директории
                            let tempDirectory = FileManager.default.temporaryDirectory
                            let fileName = UUID().uuidString + ".jpg"
                            let fileURLInTemp = tempDirectory.appendingPathComponent(fileName)
                            do {
                                try data.write(to: fileURLInTemp)
                                print("Image saved to temporary directory for still: \(still.previewURL ?? "")")

                                let stringToGetFileFromTemp = fileURLInTemp.path
//                                print("1.key - stringForLoadAvatarForNet - \(stringForLoadAvatarForNet)")
//                                print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
                                stillsWithPreviews[index].cachedPreview = stringToGetFileFromTemp

                                cacheManager.setObject(stringToGetFileFromTemp, forKey: stringForLoadStillFromNet) { _ in
//                                    print("1.key - stringForLoadAvatarForNet - \(stringForLoadAvatarForNet)")
//                                    print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
                                    print("stringToGetFileFromTemp saved to coreData for still: \(still.previewURL ?? "")")
                                }
                            } catch {
                                print("Failed to save image to temporary directory: \(error)")
                            }

                        case .failure(let error):
                            print("Failed to load image: \(error)")
                        }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(stillsWithPreviews))
        }
    }

}

// MARK: - Extensions
extension NetworkManager: NetworkManagerProtocol {

    func downloadAndCacheAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
        var filmsWithAvatars = films
        let group = DispatchGroup()

        for (index, film) in films.enumerated() {
            guard let stringForLoadAvatarFromNet = film.posterUrlPreview, let imageUrl = URL(string: stringForLoadAvatarFromNet) else { continue }

            group.enter()
            // Проверяем, существует ли значение в кэше по ключу
            cacheManager.isObjectExist(forKey: stringForLoadAvatarFromNet) { isObjExists in
                if isObjExists {
                    //и записываем stringToGetFileFromTemp в свойство фильма
                    self.cacheManager.getObject(forKey: stringForLoadAvatarFromNet) { stringToGetFileFromTemp in
                        filmsWithAvatars[index].cachedAvatarPath = stringToGetFileFromTemp
                        group.leave()
                    }
                } else {
                    // Если объект не существует, загружаем данные из сети
                    self.networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
                        guard let self = self else {
                            group.leave()
                            return
                        }

                        switch result {
                        case .success(let data):
                            // Сохраняем файл во временной директории
                            let tempDirectory = FileManager.default.temporaryDirectory
                            let fileName = UUID().uuidString + ".jpg"
                            let fileURLInTemp = tempDirectory.appendingPathComponent(fileName)
//                            print("0.fileURLInTemp - \(fileURLInTemp)")
                            do {
                                try data.write(to: fileURLInTemp)
                                print("Image saved to temporary directory for film: \(film.nameOriginal ?? "")")

                                let stringToGetFileFromTemp = fileURLInTemp.path
//                                print("1.key - stringForLoadAvatarForNet - \(stringForLoadAvatarForNet)")
//                                print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
                                filmsWithAvatars[index].cachedAvatarPath = stringToGetFileFromTemp

                                cacheManager.setObject(stringToGetFileFromTemp, forKey: stringForLoadAvatarFromNet) { _ in
//                                    print("1.key - stringForLoadAvatarForNet - \(stringForLoadAvatarForNet)")
//                                    print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
                                    print("stringToGetFileFromTemp saved to coreData for film: \(film.nameOriginal ?? "")")
                                }
                            } catch {
                                print("Failed to save image to temporary directory: \(error)")
                            }

                        case .failure(let error):
                            print("Failed to load image: \(error)")
                        }
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            completion(.success(filmsWithAvatars))
        }
    }


    func loadFilms(page: Int, 
                   completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
        if page == 1 {
            fetchedFilmsCount = 0
        }
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
                        let films = decodedFilmsDTO.items.map { OneFilm(from: $0) }
                        self.fetchedFilmsCount += films.count
                        completion(.success(films))

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
                        let filmWithoutCover = DetailsFilm(from: decodedDetailsFilmDTO)
                        completion(.success(filmWithoutCover))

                    case .failure:
                        completion(.failure(.dataMapperError(.failAtMapping)))
                    }
                }
            case .failure(let error):
                completion(.failure(.netServiceError(error)))
            }
        }
    }

    func downloadAndCacheCover(for detailsFilm: DetailsFilm,
                                completion: @escaping (Result<DetailsFilm, NetworkManagerErrors>) -> Void) {
        guard let stringForLoadCoverFromNet = detailsFilm.coverUrl,
              let imageUrl = URL(string: stringForLoadCoverFromNet) else {
            completion(.failure(.netServiceError(.noURLForFetchingCover)))
            return
        }

        var detailsFilmWithCover = detailsFilm

        self.networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                // Сохраняем файл во временной директории
                let tempDirectory = FileManager.default.temporaryDirectory
                let fileName = UUID().uuidString + ".jpg"
                let fileURLInTemp = tempDirectory.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURLInTemp)
                    print("Image saved to temporary directory for film: \(detailsFilm.nameOriginal ?? "")")

                    let stringToGetFileFromTemp = fileURLInTemp.path
                    detailsFilmWithCover.cachedCoverPath = stringToGetFileFromTemp

                    cacheManager.setObject(stringToGetFileFromTemp, forKey: stringForLoadCoverFromNet) { _ in
//            print("1.key - stringForLoadCoverFromNet - \(stringForLoadCoverFromNet)")
//            print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
                        print("stringToGetFileFromTemp saved to coreData for film: \(detailsFilm.nameOriginal ?? detailsFilm.nameEn ?? detailsFilm.nameRu)")

                        completion(.success(detailsFilmWithCover))
                    }
                } catch {
                    print("Failed to save image to temporary directory: \(error)")
                }
            case .failure(let error):
                print("Failed to load image: \(error)")
                completion(.failure(.netServiceError(.noData)))
            }
        }
    }

    func loadFilmStills(filmId: Int,
                        pageForStills: Int,
                        completion: @escaping (Result<[OneStill], NetworkManagerErrors>) -> Void) {
        guard !isFetching, amountOfFetchedStills < maxStills else { return }
        isFetching = true

        let endpoint = KinopoiskAPI.filmImages(filmId: filmId, page: pageForStills)
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
                        let stills = decodedStillsDTO.items.map { OneStill(from: $0) }
                        self.amountOfFetchedStills += stills.count
                        self.maxStills = decodedStillsDTO.total

                        self.downloadAndCacheStills(for: stills) { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let stillWithPreviewString):
                                completion(.success(stillWithPreviewString))

                            case .failure(let error):
                                completion(.failure(.netServiceError(.noData)))
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


    //реализация с NSCache не получилась - сохраняет, но не удавалось доставать из кеша в презентере - читал, что может освободждаться...
    //    func downloadAndCacheAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
    //        var filmsWithAvatars = films
    //        let group = DispatchGroup()
    //
    //        for (index, film) in films.enumerated() {
    //            guard let imageUrl = URL(string: film.posterUrlPreview ?? "") else { continue }
    //
    //            group.enter()
    //
    //            if let cachedDataForAvatar = cacheManager.getObject(forKey: imageUrl.absoluteString) {
    //                print("Image loaded from cache for film: \(film.nameOriginal ?? "Unknown")")
    //                filmsWithAvatars[index].cachedAvatarPath = imageUrl.absoluteString
    //                group.leave()
    //            } else {
    //                self.networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
    //                    guard let self = self else {
    //                        group.leave()
    //                        return
    //                    }
    //
    //                    switch result {
    //                    case .success(let data):
    //                        self.cacheManager.setObject(data, forKey: imageUrl.absoluteString)
    //                        print("Image cached for film: \(film.nameOriginal ?? "Unknown")")
    //                        filmsWithAvatars[index].cachedAvatarPath = imageUrl.absoluteString
    //                        group.leave()
    //                    case .failure(let error):
    //                        print("Failed to load image: \(error)")
    //                        completion(.failure(.netServiceError(error)))
    //                        group.leave()
    //                    }
    //
    //                }
    //            }
    //        }
    //
    //        group.notify(queue: .global()) {
    //            print("filmsWithAvatars ___________________ \(filmsWithAvatars)")
    //            completion(.success(filmsWithAvatars))
    //        }
    //    }
}

