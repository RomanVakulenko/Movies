//
//  FilmsWorker.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol FilmsWorkingLogic {
    func loadFilms(isRefreshRequested: Bool, completion: @escaping (Result<([OneFilm],Int), NetworkManagerErrors>) -> Void)
    func loadAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void)
}


final class FilmsWorker: FilmsWorkingLogic {

    // MARK: - Private properties
    private let networkManager: NetworkManagerProtocol
    private var currentPage = 1
    private var isFetching = false
    private let totalFetchedFilms = 0

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func loadFilms(isRefreshRequested: Bool, completion: @escaping (Result<([OneFilm],Int), NetworkManagerErrors>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        if isRefreshRequested {
            currentPage = 1
        }

        // Загрузим две страницы за один раз
        var allFetchedFilms: [OneFilm] = []
        var totalFilms = 0

        // Запрос первой страницы
        networkManager.loadFilms(page: currentPage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let filmsAndTotal):
                allFetchedFilms.append(contentsOf: filmsAndTotal.0) // Добавляем фильмы первой загрузки
                totalFilms = filmsAndTotal.1
                self.currentPage += 1

                // Запрос второй порции
                self.networkManager.loadFilms(page: self.currentPage) { secondResult in
                    self.isFetching = false
                    switch secondResult {
                    case .success(let secondPageFilms):
                        allFetchedFilms.append(contentsOf: secondPageFilms.0) // Добавляем вторую порцию
                        self.currentPage += 1
                        completion(.success((allFetchedFilms, totalFilms)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                self.isFetching = false
                completion(.failure(error))
            }
        }
    }

    func loadAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
        guard !isFetching else { return }
        isFetching = true

        networkManager.downloadAndCacheAvatarsFor(films: films) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false

            switch result {
            case .success(let filmsWithPaths):
                completion(.success(filmsWithPaths))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}


