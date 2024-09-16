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
    let searchText: String
    let searchTextColor: UIColor
    let searchIcon: UIImage
    let insets: UIEdgeInsets

    init(id: AnyHashable, backColor: UIColor, searchBarAttributedPlaceholder: NSAttributedString, searchText: String, searchIcon: UIImage, searchTextColor: UIColor, insets: UIEdgeInsets) {
        self.id = id
        self.backColor = backColor
        self.searchBarAttributedPlaceholder = searchBarAttributedPlaceholder
        self.searchText = searchText
        self.searchIcon = searchIcon
        self.searchTextColor = searchTextColor
        self.insets = insets
    }
}

extension SearchViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: SearchViewModel) -> Bool {
        source.backColor == backColor &&
        source.searchBarAttributedPlaceholder == searchBarAttributedPlaceholder &&
        source.searchText == searchText &&
        source.searchIcon == searchIcon &&
        source.searchTextColor == searchTextColor &&
        source.insets == insets
    }
}

