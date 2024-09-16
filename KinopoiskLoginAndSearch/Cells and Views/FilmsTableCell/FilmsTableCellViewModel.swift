//
//  FilmsTableCellViewModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import DifferenceKit

protocol FilmsTableCellViewModelOutput: AnyObject {
    func didTapAOneFilm(_ viewModel: FilmsTableCellViewModel)
}

struct FilmsTableCellViewModel {
    let filmId: String
//    let cellBackColor: UIColor
    let filmImage: UIImage?
    let filmTitle: NSAttributedString
    let subtitle: NSAttributedString
    let rating: NSAttributedString
    let insets: UIEdgeInsets

    weak var output: FilmsTableCellViewModelOutput?

    init(filmId: String,
//         cellBackColor: UIColor,
         filmImage: UIImage?, filmTitle: NSAttributedString, subtitle: NSAttributedString, rating: NSAttributedString, insets: UIEdgeInsets, output: FilmsTableCellViewModelOutput? = nil) {
        self.filmId = filmId
//        self.cellBackColor = cellBackColor
        self.filmImage = filmImage
        self.filmTitle = filmTitle
        self.subtitle = subtitle
        self.rating = rating
        self.insets = insets
        self.output = output
    }

    func didTapCell() {
        output?.didTapAOneFilm(self)
    }
}


extension FilmsTableCellViewModel: Differentiable {
    var differenceIdentifier: String {
        filmId
    }

    func isContentEqual(to source: FilmsTableCellViewModel) -> Bool {
//        source.cellBackColor == cellBackColor &&
        source.filmImage == filmImage &&
        source.filmTitle == filmTitle &&
        source.subtitle == subtitle &&
        source.rating == rating &&
        source.insets == insets
    }
}
