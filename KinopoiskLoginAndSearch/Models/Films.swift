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

    init(from dto: OneFilmDTO) {
        self.kinopoiskId = dto.kinopoiskId
        self.imdbId = dto.imdbId
        self.nameRu = dto.nameRu
        self.nameEn = dto.nameEn
        self.nameOriginal = dto.nameOriginal
        self.countries = dto.countries
        self.genres = dto.genres
        self.ratingKinopoisk = dto.ratingKinopoisk
        self.ratingImdb = dto.ratingImdb
        self.year = dto.year
        self.type = dto.type
        self.posterUrl = dto.posterUrl
        self.posterUrlPreview = dto.posterUrlPreview
    }
}
