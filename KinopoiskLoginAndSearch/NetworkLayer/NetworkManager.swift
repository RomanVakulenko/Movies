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

//    private func downloadAndCacheAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetServiceError>) -> Void) {
//        var filmsWithAvatars = films
//        let group = DispatchGroup()
//
//        for (index, film) in films.enumerated() {
//            guard let imageUrl = URL(string: film.posterUrlPreview ?? "") else {
//                continue
//            }
//
//            group.enter()
//            cacheManager.getObject(forKey: imageUrl.absoluteString) { cachedDataForAvatar in
//                if cachedDataForAvatar != nil {
//                    print("Image loaded from cache for film: \(film.nameOriginal)")
//                    filmsWithAvatars[index].cachedAvatarPath = imageUrl.absoluteString
//                    group.leave()
//                } else {
//                    self.networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
//                        guard let self = self else {
//                            group.leave()
//                            return
//                        }
//
//                        switch result {
//                        case .success(let data):
//                            self.cacheManager.setObject(data, forKey: imageUrl.absoluteString) {
//                                print("Image cached for film: \(film.nameOriginal)")
//                                filmsWithAvatars[index].cachedAvatarPath = imageUrl.absoluteString
//                            }
//                        case .failure(let error):
//                            print("Failed to load image: \(error)")
//                            group.leave()
//                        }
//
//                    }
//                }
//            }
//        }
//        group.notify(queue: .global()) {
//            completion(.success(filmsWithAvatars))
//        }
//    }

//    private func downloadAndCacheCover(for detailsFilm: DetailsFilm,
//                                       completion: @escaping (Result<DetailsFilm, NetServiceError>) -> Void) {
//        guard let imageUrl = URL(string: detailsFilm.coverUrl ?? "") else {
//            completion(.success(detailsFilm))
//            return
//        }
//
//        var detailsFilmWithCover = detailsFilm
//
//        cacheManager.getObject(forKey: imageUrl.absoluteString) { [weak self] cachedData in
//            if cachedData != nil {
//                print("Image loaded from cache for detailsFilm: \(detailsFilmWithCover.nameOriginal)")
//                detailsFilmWithCover.coverUrl = imageUrl.absoluteString
//                completion(.success(detailsFilmWithCover))
//            } else {
//                self?.networkService.requestDataWith(URLRequest(url: imageUrl)) { result in
//                    switch result {
//                    case .success(let data):
//                        self?.cacheManager.setObject(data, forKey: imageUrl.absoluteString) {
//                            print("Image cached for detailsFilm: \(detailsFilmWithCover.nameOriginal)")
//                            detailsFilmWithCover.coverUrl = imageUrl.absoluteString
//                            completion(.success(detailsFilmWithCover))
//                        }
//                    case .failure(let error):
//                        print("Failed to load image: \(error)")
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//    }

//    private func downloadAndCacheStills(for stills: [OneStill],
//                                        completion: @escaping (Result<[OneStill], NetServiceError>) -> Void) {
//        let group = DispatchGroup()
//        var stillsWithPreviews = stills
//
//        for index in stillsWithPreviews.indices {
//            guard let imageUrl = URL(string: stillsWithPreviews[index].previewURL ?? "") else { continue }
//
//            group.enter()
//            cacheManager.getObject(forKey: imageUrl.absoluteString) { [weak self] cachedDataForStill in
//                if cachedDataForStill != nil {
//                    print("Image loaded from cache for previewURL: \(stillsWithPreviews[index].previewURL ?? "")")
//                    stillsWithPreviews[index].cachedPreview = imageUrl.absoluteString
//                    group.leave()
//                } else {
//                    self?.networkService.requestDataWith(URLRequest(url: imageUrl)) { result in
//
//                        switch result {
//                        case .success(let data):
//                            self?.cacheManager.setObject(data, forKey: imageUrl.absoluteString) {
//                                print("Image cached for previewURL: \(stillsWithPreviews[index].previewURL ?? "")")
//                                stillsWithPreviews[index].cachedPreview = imageUrl.absoluteString
//                                group.leave()
//                            }
//                        case .failure(let error):
//                            print("Failed to load image: \(error)")
//                            group.leave()
//                        }
//                    }
//                }
//            }
//        }
//
//        group.notify(queue: .main) {
//            completion(.success(stillsWithPreviews))
//        }
//    }

}

// MARK: - Extensions
extension NetworkManager: NetworkManagerProtocol {

//реализация с NSCache не получилась - сохраняет, но не удавалось доставать из кеша в презентере
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
    func downloadAndCacheAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
        var filmsWithAvatars = films
        let group = DispatchGroup()

        for (index, film) in films.enumerated() {
            guard let stringForLoadAvatarForNet = film.posterUrlPreview, let imageUrl = URL(string: stringForLoadAvatarForNet) else { continue }

            group.enter()
            // Проверяем, существует ли значение в кэше по ключу
            cacheManager.isObjectExist(forKey: stringForLoadAvatarForNet) { isObjExists in
                if isObjExists {
                    //и записываем stringToGetFileFromTemp в свойство фильма
                    self.cacheManager.getObject(forKey: stringForLoadAvatarForNet) { stringToGetFileFromTemp in
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
                            print("0.fileURLInTemp - \(fileURLInTemp)")
                            do {
                                try data.write(to: fileURLInTemp)
                                print("Image saved to temporary directory for film: \(film.nameOriginal ?? "")")

                                let stringToGetFileFromTemp = fileURLInTemp.path
                                print("1.key - stringForLoadAvatarForNet - \(stringForLoadAvatarForNet)")
                                print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
                                filmsWithAvatars[index].cachedAvatarPath = stringToGetFileFromTemp

                                cacheManager.setObject(stringToGetFileFromTemp, forKey: stringForLoadAvatarForNet) { _ in
                                    print("1.key - stringForLoadAvatarForNet - \(stringForLoadAvatarForNet)")
                                    print("2.stringToGetFileFromTemp - \(stringToGetFileFromTemp)")
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


//    func downloadAndCacheAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
//        var filmsWithAvatars = films
//        let group = DispatchGroup()
//
//        for (index, film) in films.enumerated() {
//            guard let imageUrl = URL(string: film.posterUrlPreview ?? "") else {
//                continue
//            }
//
//            group.enter()
//
//            if FileManager.default.fileExists(atPath: film.cachedAvatarPath ?? "") {
//                // Если файл существует, загружаем изображение из файла
//                if let data = try? Data(contentsOf: URL(fileURLWithPath: film.cachedAvatarPath ?? "")),
//                   let image = UIImage(data: data) {
//                    print("Image loaded from file for film: \(film.nameOriginal ?? "")")
//                    filmsWithAvatars[index].cachedAvatarPath = film.cachedAvatarPath
//                    group.leave()
//                    continue
//                }
//            }
//
//            // Если нет в UserPreferences или файл не найден, загружаем из сети
//            self.networkService.requestDataWith(URLRequest(url: imageUrl)) { [weak self] result in
//                guard let self = self else {
//                    group.leave()
//                    return
//                }
//
//                switch result {
//                case .success(let data):
//                    // Сохраняем во временное хранилище
//                    let tempDirectory = FileManager.default.temporaryDirectory
//                    let fileName = UUID().uuidString + ".jpg" // Уникальное имя файла
//                    let fileURL = tempDirectory.appendingPathComponent(fileName)
//
//                    do {
//                        try data.write(to: fileURL)
//                        print("Image saved to temporary directory for film: \(film.nameOriginal ?? "")")
//
//                        // Обновляем UserPreferences с новым путем
//                        var currentPaths = UserPreferences.shared.avatarPaths
//                        currentPaths.append(fileURL.path)
//                        UserPreferences.shared.avatarPaths = currentPaths
//
//                        filmsWithAvatars[index].cachedAvatarPath = fileURL.path
//                    } catch {
//                        print("Failed to save image to temporary directory: \(error)")
//                    }
//
//                case .failure(let error):
//                    print("Failed to load image: \(error)")
//                }
//                group.leave()
//            }
//        }
//
//        group.notify(queue: .global()) {
//            completion(.success(filmsWithAvatars))
//        }
//    }


    func loadFilms(page: Int, completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
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
                        let film = DetailsFilm(from: decodedDetailsFilmDTO)
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
                        let stills = decodedStillsDTO.items.map { OneStill(from: $0) }
                        self.maxStills = decodedStillsDTO.total
                        completion(.success(stills))

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

