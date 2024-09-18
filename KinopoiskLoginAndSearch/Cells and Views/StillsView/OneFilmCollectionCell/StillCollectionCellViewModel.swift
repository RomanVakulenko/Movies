//
//  StillCollectionCellViewModel.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 15.09.2024.
//

import UIKit
import DifferenceKit


// MARK: - StillCollectionCellViewModelOutput

protocol StillCollectionCellViewModelOutput: AnyObject {
    func didTapAtOneStill(_ viewModel: StillCollectionCellViewModel)
}

struct StillCollectionCellViewModel {
    let id: String
    let stillImage: UIImage?

    weak var output: StillCollectionCellViewModelOutput?

    init(id: String, stillImage: UIImage?, output: StillCollectionCellViewModelOutput? = nil) {
        self.id = id
        self.stillImage = stillImage
        self.output = output
    }

    func didTapAtOneStill() {
        output?.didTapAtOneStill(self)
    }
}

// MARK: - Extensions
extension StillCollectionCellViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: StillCollectionCellViewModel) -> Bool {
        source.stillImage == stillImage
    }
}
