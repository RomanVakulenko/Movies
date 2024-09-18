//
//  OneFilmDetailsPresenter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import DifferenceKit

protocol OneFilmDetailsPresentationLogic {
    func presentUpdateAllButStills(response: OneFilmDetailsFlow.UpdateAllButStills.Response)
    func presentUpdateStills(response: OneFilmDetailsFlow.UpdateStills.Response)

    func presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response)
    func presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response)

    func presentRouteToWeb(response: OneFilmDetailsFlow.OnWebLinkTap.Response)

}


final class OneFilmDetailsPresenter: OneFilmDetailsPresentationLogic {

    enum Constants {
        static let mainImageWidthHeight: CGFloat = 45
        static let leftRightInset: CGFloat = 8
        static let idForStillsVM: CGFloat = 8
    }

    // MARK: - Public properties

    weak var viewController: OneFilmDetailsDisplayLogic?

    // MARK: - Public methods
    func presentRouteToWeb(response: OneFilmDetailsFlow.OnWebLinkTap.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToWeb(viewModel: OneFilmDetailsFlow.OnWebLinkTap.ViewModel())
        }
    }

    func presentUpdateAllButStills(response: OneFilmDetailsFlow.UpdateAllButStills.Response) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let film = response.film

            let backColor = UIHelper.Color.almostBlack

            //потенциально долгие операции
            let backChevron = UIImage(systemName: "chevron.backward")
            let coverView = UIImage(contentsOfFile: film.coverUrl ?? "")
            let linkIcon = UIImage(systemName: "link")

            let filmTitle = NSAttributedString(string: film.nameOriginal ?? "Нет названия",
                                               attributes: UIHelper.Attributed.whiteInterBold18)
            let filmRating = NSAttributedString(string: String(film.ratingKinopoisk ?? 0),
                                                attributes: UIHelper.Attributed.cyanSomeBold18)
            let descriptionTitle = NSAttributedString(string: GlobalConstants.filmDescriptionTtile,
                                                      attributes: UIHelper.Attributed.whiteInterBold22)
            let descriptionText = NSAttributedString(string: film.description ?? "Нет описания",
                                                     attributes: UIHelper.Attributed.grayMedium14)

            let genres = NSAttributedString(
                string: "\(film.genres.map { $0.genre.lowercased() }.joined(separator: ", "))",
                attributes: UIHelper.Attributed.whiteInterBold18)
            let yearsAndCountries = NSAttributedString(
                string: "\(film.startYear) - \(film.endYear), \(film.countries.map { $0.country }.joined(separator: ", "))",
                attributes: UIHelper.Attributed.whiteInterBold18)

            let stillTitle = NSAttributedString(string: GlobalConstants.stills,
                                                attributes: UIHelper.Attributed.whiteInterBold22)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.displayUpdateAllButStills(viewModel: OneFilmDetailsFlow.UpdateAllButStills.ViewModel(
                    backViewColor: backColor,
                    backChevron: backChevron ?? UIImage(),
                    coverView: coverView ?? UIImage(),
                    linkIcon: linkIcon ?? UIImage(),
                    filmTitle: filmTitle,
                    filmRating: filmRating,
                    descriptionTitle: descriptionTitle,
                    descriptionText: descriptionText,
                    genres: genres,
                    yearsAndCountries: yearsAndCountries,
                    stillTitle: stillTitle))
            }
        }
    }

    func presentUpdateStills(response: OneFilmDetailsFlow.UpdateStills.Response) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let stills = response.stills else { return }

            var views: [AnyDifferentiable] = []

            let stillsViewModel = self.makeStillsVM(stills: stills)
            views.append(stillsViewModel)

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.displayUpdateStills(viewModel: OneFilmDetailsFlow.UpdateStills.ViewModel(
                    id: stillsViewModel.differenceIdentifier,
                    items: views))
            }

        }
    }


    func presentAlert(response: OneFilmDetailsFlow.AlertInfo.Response) {
        let title = GlobalConstants.error
        let text = response.error.localizedDescription
        let buttonTitle = GlobalConstants.ok

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(
                viewModel: OneFilmDetailsFlow.AlertInfo.ViewModel(title: title,
                                                                  text: text,
                                                                  buttonTitle: buttonTitle))
        }
    }

    func presentWaitIndicator(response: OneFilmDetailsFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: OneFilmDetailsFlow.OnWaitIndicator.ViewModel(
                isShow: response.isShow,
                type: response.type))
        }
    }

    // MARK: - Private methods

    private func makeStillsVM(stills: [OneStill]) -> AnyDifferentiable {

        var collectionOfStills: [AnyDifferentiable] = []

        for oneStill in stills {
            let oneStillCellVM = makeCellForCollection(id: oneStill.previewURL,
                                                       urlInCache: oneStill.cachedPreview)
            collectionOfStills.append(oneStillCellVM)
        }

        let stillsVM = StillsViewModel(
            id: Constants.idForStillsVM,
            //                insets:  UIEdgeInsets(top: UIHelper.Margins.medium8px,
            //                                      left: UIHelper.Margins.medium16px,
            //                                      bottom: UIHelper.Margins.medium8px,
            //                                      right: UIHelper.Margins.medium16px),
            items: collectionOfStills)

        return AnyDifferentiable(stillsVM)

    }


    private func makeCellForCollection(id: String?, urlInCache: String?) -> AnyDifferentiable {
        let stillImage = UIImage(contentsOfFile: urlInCache ?? "")
        let oneStillCellVM = StillCollectionCellViewModel(id: id ?? "",
                                                          stillImage: stillImage)
        return AnyDifferentiable(oneStillCellVM)
    }

}

