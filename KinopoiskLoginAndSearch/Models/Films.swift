//
//  Films.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 15.09.2024.
//

import Foundation


// MARK: - DTO
struct FilmsDTO: Codable {
    let total, totalPages: Int
    let items: [OneFilmDTO]
}

struct OneFilmDTO: Codable {
    let kinopoiskID: Int?
    let imdbID, nameRu, nameEn, nameOriginal: String?
    let countries: [Country]
    let genres: [Genre]
    let ratingKinopoisk, ratingImdb: Double?
    let year: Int?
    let type: String?
    let posterURL: String?
    let posterURLPreview: String?

    enum CodingKeys: String, CodingKey {
        case kinopoiskID = "kinopoiskId"
        case imdbID = "imdbId"
        case nameRu, nameEn, nameOriginal, countries, genres, ratingKinopoisk, ratingImdb, year, type
        case posterURL = "posterUrl"
        case posterURLPreview = "posterUrlPreview"
    }
}

struct Country: Codable {
    let country: String
}

struct Genre: Codable {
    let genre: String
}

struct DetailsFilmDTO: Codable {
    let kinopoiskID: Int
    let nameRu, nameEn, nameOriginal: String?
    let coverURL: String?
    let ratingKinopoisk: Double?
    let webURL: String?
    let description, shortDescription: String?
    let countries: [Country]
    let genres: [Genre]
    let startYear, endYear: Int?

    enum CodingKeys: String, CodingKey {
        case kinopoiskID = "kinopoiskId"
        case nameRu, nameEn, nameOriginal
        case coverURL = "coverUrl"
        case ratingKinopoisk
        case webURL = "webUrl"
        case description, shortDescription
        case countries
        case genres
        case startYear, endYear
    }
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
    let nameOriginal: String?
    let countries: [Country]
    let genres: [Genre]
    let ratingKinopoisk: Double?
    let year: Int?
    let posterUrlPreview: String?
    var cachedAvatarPath: String?

    init(from dto: OneFilmDTO) {
        self.kinopoiskId = dto.kinopoiskID ?? 0
        self.nameRu = dto.nameRu
        self.nameEn = dto.nameEn
        self.nameOriginal = dto.nameOriginal ?? dto.nameRu ?? dto.nameEn
        self.countries = dto.countries
        self.genres = dto.genres
        self.ratingKinopoisk = dto.ratingKinopoisk
        self.year = dto.year ?? 1000
        self.posterUrlPreview = dto.posterURLPreview
        self.cachedAvatarPath = nil
    }
}


struct DetailsFilm {
    let kinopoiskId: Int
    let nameRu, nameEn, nameOriginal: String?
    var coverUrl: String?
    let ratingKinopoisk: Double?
    let webUrl: String?
    let description: String?
    let shortDescription: String?
    let countries: [Country]
    let genres: [Genre]
    let startYear: Int?
    let endYear: Int?
    var stills: [OneStill]?

    init(from dto: DetailsFilmDTO) {
        self.kinopoiskId = dto.kinopoiskID
        self.nameRu = dto.nameRu
        self.nameEn = dto.nameEn
        self.nameOriginal = dto.nameOriginal ?? dto.nameEn ?? dto.nameRu
        self.coverUrl = dto.coverURL
        self.ratingKinopoisk = dto.ratingKinopoisk
        self.webUrl = dto.webURL
        self.description = dto.description
        self.shortDescription = dto.shortDescription
        self.countries = dto.countries
        self.genres = dto.genres
        self.startYear = dto.startYear
        self.endYear = dto.endYear
        self.stills = nil
    }
}
