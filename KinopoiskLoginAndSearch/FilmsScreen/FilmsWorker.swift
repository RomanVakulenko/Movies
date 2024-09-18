//
//  FilmsWorker.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

protocol FilmsWorkingLogic {
    func loadFilms(isRefreshRequested: Bool, completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void)
    func loadAvatarsFor(films: [OneFilm], completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void)
}


final class FilmsWorker: FilmsWorkingLogic {

    // MARK: - Private properties
    private let networkManager: NetworkManagerProtocol
    private var currentPage = 1
    private var isFetching = false

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func loadFilms(isRefreshRequested: Bool, completion: @escaping (Result<[OneFilm], NetworkManagerErrors>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        if isRefreshRequested {
            currentPage = 1
        }

        networkManager.loadFilms(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false

            switch result {
            case .success(let films):
                self.currentPage += 1
                completion(.success(films))
            case .failure(let error):
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


