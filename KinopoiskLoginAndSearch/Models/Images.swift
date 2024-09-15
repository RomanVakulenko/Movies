//
//  Images.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import Foundation

// MARK: - DTO

struct OneFilmImagesDTO: Codable {
    let total: Int
    let totalPages: Int
    let items: [ImageUrlsDTO]
}

struct ImageUrlsDTO: Codable {
    let imageUrl: String
    let previewUrl: String
}


// MARK: - Business

struct OneFilmImages {
    let total: Int
    let totalPages: Int
    let images: [OneFilmImage]

    init(from dto: OneFilmImagesDTO) {
        self.total = dto.total
        self.totalPages = dto.totalPages
        self.images = dto.items.map { OneFilmImage(from: $0) }
    }
}

struct OneFilmImage {
    let imageURL: URL
    let previewURL: URL

    init(from dto: ImageUrlsDTO) {
        self.imageURL = URL(string: dto.imageUrl)!
        self.previewURL = URL(string: dto.previewUrl)!
    }
}


