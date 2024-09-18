//
//  SearchViewModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import DifferenceKit


struct SearchViewModel {
    let id: AnyHashable
    let backColor: UIColor

    let searchBarAttributedPlaceholder: NSAttributedString
    let searchTextColor: UIColor
    let searchIcon: UIImage

    init(id: AnyHashable, backColor: UIColor, searchBarAttributedPlaceholder: NSAttributedString, searchIcon: UIImage, searchTextColor: UIColor) {
        self.id = id
        self.backColor = backColor
        self.searchBarAttributedPlaceholder = searchBarAttributedPlaceholder
//        self.searchText = searchText
        self.searchIcon = searchIcon
        self.searchTextColor = searchTextColor
    }
}

extension SearchViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: SearchViewModel) -> Bool {
        source.backColor == backColor &&
        source.searchBarAttributedPlaceholder == searchBarAttributedPlaceholder &&
//        source.searchText == searchText &&
        source.searchIcon == searchIcon &&
        source.searchTextColor == searchTextColor
    }
}

