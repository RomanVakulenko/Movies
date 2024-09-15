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
    func didTapAtCell(_ viewModel: StillCollectionCellViewModel)
}

struct StillCollectionCellViewModel {
    let id: String
    let still: UIImage?

    weak var output: StillCollectionCellViewModelOutput?

    init(id: String, still: UIImage?, output: StillCollectionCellViewModelOutput? = nil) {
        self.id = id
        self.still = still
        self.output = output
    }

    func didTapStill() {
        output?.didTapAtCell(self)
    }
}

// MARK: - Extensions
extension StillCollectionCellViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: StillCollectionCellViewModel) -> Bool {
        source.still == still
    }
}
