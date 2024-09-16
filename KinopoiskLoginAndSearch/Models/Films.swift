//
//  Films.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 15.09.2024.
//

import Foundation


// MARK: - DTO

struct FilmsDTO: Codable {
    let total: Int
    let totalPages: Int
    let items: [OneFilmDTO]
}

struct OneFilmDTO: Codable {
    let kinopoiskId: Int
    let imdbId: String?
    let nameRu: String?
    let nameEn: String?
    let nameOriginal: String
    let countries: [Country]
    let genres: [Genre]
    let ratingKinopoisk: Double?
    let ratingImdb: Double?
    let year: Int
    let type: String
    let posterUrl: String
    let posterUrlPreview: String
}

struct Country: Codable {
    let country: String
}

struct Genre: Codable {
    let genre: String
}

struct DetailsFilmDTO: Codable {
    let kinopoiskId: Int
    let nameOriginal: String
    let coverUrl: String?
    let ratingKinopoisk: Double
    let webUrl: String
    let description: String
    let shortDescription: String
    let countries: [Country]
    let genres: [Genre]
    let startYear: Int
    let endYear: Int
}


// MARK: - Business

struct Films {
    let total: Int
    let totalPages: Int
    let items: [OneFilm]

    init(from dto: FilmsDTO) {
        self.total = dto.total
        self.totalPages = dto.totalPages
        self.items = dto.items.map { OneFilm(from: $0) }
    }
}

struct OneFilm {
    let kinopoiskId: Int
    let nameRu: String?
    let nameEn: String?
    let nameOriginal: String
    let countries: [Country]
    let genres: [Genre]
    let ratingKinopoisk: Double?
    let year: Int
    let posterUrlPreview: String
    var cachedAvatarPath: String?

    init(from dto: OneFilmDTO) {
        self.kinopoiskId = dto.kinopoiskId
        self.nameRu = dto.nameRu
        self.nameEn = dto.nameEn
        self.nameOriginal = dto.nameOriginal
        self.countries = dto.countries
        self.genres = dto.genres
        self.ratingKinopoisk = dto.ratingKinopoisk
        self.year = dto.year
        self.posterUrlPreview = dto.posterUrlPreview
        self.cachedAvatarPath = nil
    }
}


struct DetailsFilm {
    let kinopoiskId: Int
    let nameOriginal: String
    var coverUrl: String?
    let ratingKinopoisk: Double
    let webUrl: String
    let description: String
    let shortDescription: String
    let countries: [Country]
    let genres: [Genre]
    let startYear: Int
    let endYear: Int
    var cachedStillsPaths: [String]?

    init(from dto: DetailsFilmDTO) {
        self.kinopoiskId = dto.kinopoiskId
        self.nameOriginal = dto.nameOriginal
        self.coverUrl = dto.coverUrl
        self.ratingKinopoisk = dto.ratingKinopoisk
        self.webUrl = dto.webUrl
        self.description = dto.description
        self.shortDescription = dto.shortDescription
        self.countries = dto.countries
        self.genres = dto.genres
        self.startYear = dto.startYear
        self.endYear = dto.endYear
        self.cachedStillsPaths = nil
    }
}
