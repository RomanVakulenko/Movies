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
        let group = DispatchGroup()
        var coverView: UIImage?

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                group.leave()
                return
            }
            let film = response.film
            let backColor = UIHelper.Color.almostBlack
            let backChevron = UIImage(systemName: "chevron.backward")

            if let path = film.cachedCoverPath, !path.isEmpty {
                DispatchQueue.global(qos: .background).async {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                        coverView = UIImage(data: data) ?? UIHelper.Images.imagePlaceholder100px
                    } else {
                        coverView = UIHelper.Images.imagePlaceholder100px
                    }
                    group.leave()
                }
            } else {
                coverView = UIHelper.Images.imagePlaceholder100px
                group.leave()
            }

            group.notify(queue: .main) {
                let linkIcon = UIImage(systemName: "link")
                let filmTitle = NSAttributedString(
                    string: film.nameOriginal ?? film.nameRu ?? film.nameEn ?? "Нет названия",
                    attributes: UIHelper.Attributed.whiteInterBold18)

                let filmRating = NSAttributedString(
                    string: String(film.ratingKinopoisk ?? 0),
                    attributes: UIHelper.Attributed.cyanSomeBold18)

                let descriptionTitle = NSAttributedString(
                    string: GlobalConstants.filmDescriptionTtile,
                    attributes: UIHelper.Attributed.whiteInterBold22)

                let descriptionText = NSAttributedString(
                    string: film.description ?? "Нет описания",
                    attributes: UIHelper.Attributed.grayMedium14)

                let genres = NSAttributedString(
                    string: "\(film.genres.map { $0.genre.lowercased() }.joined(separator: ", "))",
                    attributes: UIHelper.Attributed.whiteInterBold18)

                var textForYears = ""
                if let start = film.startYear, let end = film.endYear {
                    textForYears = "\(start) - \(end), "
                }

                let yearsAndCountries = NSAttributedString(
                    string: textForYears + "\(film.countries.map { $0.country }.joined(separator: ", "))",
                    attributes: UIHelper.Attributed.whiteInterBold18)

                let stillsTitle = NSAttributedString(
                    string: GlobalConstants.stills,
                    attributes: UIHelper.Attributed.whiteInterBold22)

                self.viewController?.displayUpdateAllButStills(viewModel: OneFilmDetailsFlow.UpdateAllButStills.ViewModel(
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
                    stillsTitle: stillsTitle))
            }
        }
    }



    func presentUpdateStills(response: OneFilmDetailsFlow.UpdateStills.Response) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let stills = response.stills else { return }

            var items: [AnyDifferentiable] = []

            makeStillsVM(stills: stills) { stillsViewModel in
                items.append(stillsViewModel)

                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.displayUpdateStills(viewModel: OneFilmDetailsFlow.UpdateStills.ViewModel(
                        id: stillsViewModel.differenceIdentifier,
                        items: items))
                }
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

    private func makeStillsVM(stills: [OneStill], completion: @escaping (AnyDifferentiable) -> Void) {

        var collectionOfStills: [AnyDifferentiable] = []
        var dictStillsViewModels: Dictionary<Int, StillCollectionCellViewModel> = [:]

        let group = DispatchGroup()
        let queueForDict = DispatchQueue(label: "com.stills.queueForDict", attributes: .concurrent)

        for (index, still) in stills.enumerated() {
            group.enter()
            makeCellForCollection(id: still.previewURL,
                                  index: index,
                                  urlInCache: still.cachedPreview) { (oneStillViewModel, index) in
                queueForDict.async(flags: .barrier) { // //чтобы одновременного обращения к словарю не было
                    dictStillsViewModels[index] = oneStillViewModel
                    group.leave()
                }
            }
        }

        group.notify(queue: DispatchQueue.global()) {
            queueForDict.sync { // Последовательное чтение словаря после завершения всех операций записи
                if dictStillsViewModels.count > 0 {
                    for index in 0..<dictStillsViewModels.count {
                        if let contactCellVM = dictStillsViewModels[index] {
                            collectionOfStills.append(AnyDifferentiable(contactCellVM))
                        }
                    }
                }
            }

            let stillsVM = StillsViewModel(
                id: Constants.idForStillsVM,
                //                insets:  UIEdgeInsets(top: UIHelper.Margins.medium8px,
                //                                      left: UIHelper.Margins.medium16px,
                //                                      bottom: UIHelper.Margins.medium8px,
                //                                      right: UIHelper.Margins.medium16px),
                items: collectionOfStills)

            completion(AnyDifferentiable(stillsVM))
        }
    }



    private func makeCellForCollection(id: String?,
                                       index: Int,
                                       urlInCache: String?,
                                       completion: @escaping  (StillCollectionCellViewModel, Int) -> Void) {

        var stillImage: UIImage?
        if let path = urlInCache,
           path != "" {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {// или так доставать data из FileManager.default.contents(atPath: path)
                stillImage = UIImage(data: data) ?? UIHelper.Images.imagePlaceholder100px
            }
        } else {
            stillImage = UIHelper.Images.imagePlaceholder100px
        }

        let oneStillCellVM = StillCollectionCellViewModel(id: id ?? "", stillImage: stillImage)
        completion(oneStillCellVM, index)
    }

}

