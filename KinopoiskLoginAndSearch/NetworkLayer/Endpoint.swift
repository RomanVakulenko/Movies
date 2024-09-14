//
//  Endpoint.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation


final class EndPont {
    private init() {}
    static var shared = EndPont()

    private var baseURL: String {
        return "https://kinopoiskapiunofficial.tech/api/v2.2/films/"
    }

    func urlFor(variant: Variant) -> URL? {
        var urlComponents = URLComponents(string: baseURL + variant.path)
        urlComponents?.queryItems = variant.queryItems
        return urlComponents?.url
    }
}

extension EndPont {

    enum Variant {
        case id
        case images

        var path: String {
            switch self {
            case .id:
                return "77044"
            case .images:
                return "https://kinopoiskapiunofficial.tech/api/v2.2/films/77044/images?page=" //дописывать страницу 1, 2. и т/д/
            }
        }

        var queryItems: [URLQueryItem] {
            switch self {
            case .pricesForLatest:
                return [
                    URLQueryItem(name: "currency", value: "rub"),
                    URLQueryItem(name: "period_type", value: "year"),
                    URLQueryItem(name: "page", value: "1"),
                    URLQueryItem(name: "limit", value: "30"),
                    URLQueryItem(name: "show_to_affiliates", value: "false"),
                    URLQueryItem(name: "token", value: Use.token)
                ]
            }
        }
    }
}
