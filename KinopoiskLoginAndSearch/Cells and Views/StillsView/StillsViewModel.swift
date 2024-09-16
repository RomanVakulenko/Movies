//
//  StillsViewModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 16.09.2024.
//

import Foundation
import DifferenceKit


struct StillsViewModel {
    let id: AnyHashable
    let insets: UIEdgeInsets
    let items: [AnyDifferentiable]

    init(id: AnyHashable,
         insets: UIEdgeInsets,
         items: [AnyDifferentiable]) {
        self.id = id
        self.insets = insets
        self.items = items
    }
}

extension StillsViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: StillsViewModel) -> Bool {
        source.insets == insets
    }
}

