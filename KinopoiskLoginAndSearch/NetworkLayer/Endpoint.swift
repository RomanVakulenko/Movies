//
//  Endpoint.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation


enum KinopoiskAPI {
    static let baseURL = "https://kinopoiskapiunofficial.tech/api/v2.2/films"
    static let apiKey = "e366973a-2ae8-4a4e-94f2-c67f51da6d62"

    case filmDetails(id: Int)
    case filmsByPage(page: Int, order: String = "RATING", type: String = "ALL", ratingFrom: Int = 0, ratingTo: Int = 10, yearFrom: Int = 1900, yearTo: Int = 2030)
    case filmImages(id: Int, type: String = "STILL", page: Int)

    var urlString: String {
        switch self {
        case .filmDetails(let id):
            return "\(KinopoiskAPI.baseURL)/\(id)"
        case .filmsByPage(let page, let order, let type, let ratingFrom, let ratingTo, let yearFrom, let yearTo):
            return "\(KinopoiskAPI.baseURL)?order=\(order)&type=\(type)&ratingFrom=\(ratingFrom)&ratingTo=\(ratingTo)&yearFrom=\(yearFrom)&yearTo=\(yearTo)&page=\(page)"
        case .filmImages(let id, let type, let page):
            return "\(KinopoiskAPI.baseURL)/\(id)/images?type=\(type)&page=\(page)"
        }
    }
}
