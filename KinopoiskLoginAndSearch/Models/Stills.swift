//
//  Stills.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import Foundation

// MARK: - DTO

struct StillsDTO: Codable {
    let total: Int
    let totalPages: Int
    let items: [OneStillDTO]
}

struct OneStillDTO: Codable {
    let previewUrl: String?
}


// MARK: - Business

struct Stills {
    let total: Int
    let totalPages: Int
    let images: [OneStill]

    init(from dto: StillsDTO) {
        self.total = dto.total
        self.totalPages = dto.totalPages
        self.images = dto.items.map { OneStill(from: $0) }
    }
}

struct OneStill {
    let previewURL: String?
    var cachedPreview: String?

    init(from dto: OneStillDTO) {
        self.previewURL = dto.previewUrl
        self.cachedPreview = nil
    }
}


