//
//  AddressBookModels.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import DifferenceKit
import UIKit

enum FilmsModel {

    struct ViewModel {
        let backViewColor: UIColor
        let navBarBackground: UIColor
        let navBar: CustomNavBar

        let screenTitle: NSAttributedString
        let rightNavBarItem: UIImage

        let yearButtonText: NSAttributedString
        let sortIcon: UIImage
        let searchViewModel: SearchViewModel

        let items: [AnyDifferentiable]
        let insets: UIEdgeInsets
    }

    // MARK: - FilmsDTO
    struct FilmsDTO: Codable {
        let total: Int
        let totalPages: Int
        let items: [OneFilmDTO]
    }

    // MARK: - OneFilmDTO
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

}
