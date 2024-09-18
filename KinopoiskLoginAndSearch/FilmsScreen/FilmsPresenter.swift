//
//  FilmsPresenter.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit
import DifferenceKit
import SnapKit

protocol FilmsPresentationLogic {
    func presentRouteBackToLoginScreen(response: FilmsScreenFlow.OnSelectItem.Response)
    func presentRouteToOneFilmDetails(response: FilmsScreenFlow.RoutePayload.Response)

    func presentSearchBar(response: FilmsScreenFlow.UpdateSearch.Response)
    func presentUpdate(response: FilmsScreenFlow.Update.Response)

    func presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response)
    func presentAlert(response: FilmsScreenFlow.AlertInfo.Response)

}


final class FilmsPresenter: FilmsPresentationLogic {

    enum Constants {
        static let mainImageWidthHeight: CGFloat = 45
        static let searchViewId: Int = 1
    }

    // MARK: - Public properties

    weak var viewController: FilmsDisplayLogic?

    // MARK: - Public methods

    func presentRouteBackToLoginScreen(response: FilmsScreenFlow.OnSelectItem.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteBackToLoginScreen(viewModel: FilmsScreenFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToOneFilmDetails(response: FilmsScreenFlow.RoutePayload.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToOneFilmDetails(viewModel: FilmsScreenFlow.RoutePayload.ViewModel())
        }
    }

    func presentSearchBar(response: FilmsScreenFlow.UpdateSearch.Response) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            let backColor = UIHelper.Color.almostBlack

            let searchBarAttributedPlaceholder = NSAttributedString(
                string: GlobalConstants.searchBarPlaceholder,
                attributes: UIHelper.Attributed.grayMedium14)

            let searchTextColor = UIHelper.Color.gray
            let searchIcon = UIImage(systemName: "magnifyingglass")

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.displaySearchView(viewModel: FilmsScreenFlow.UpdateSearch.ViewModel(
                    id: Constants.searchViewId,
                    backColor: backColor,
                    searchBarAttributedPlaceholder: searchBarAttributedPlaceholder,
                    searchIcon: searchIcon ?? UIImage(),
                    searchTextColor: searchTextColor))
            }
        }
    }


    func presentUpdate(response: FilmsScreenFlow.Update.Response) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let films = response.filmsSortedFiltered else { return }

            let backColor = UIHelper.Color.almostBlack
            let textForScreenTitle = GlobalConstants.appTitle
            let screenTitle = NSAttributedString(
                string: textForScreenTitle,
                attributes: UIHelper.Attributed.cyanSomeBold22)


            let rightNavBarItem = NavBarButton(image: UIHelper.Images.logOffCyan24px)
            let navBar = CustomNavBar(title: screenTitle,
                                      isLeftBarButtonEnable: true,
                                      isLeftBarButtonCustom: false,
                                      leftBarButtonCustom: nil,
                                      rightBarButtons: [rightNavBarItem])

            let sortIcon = UIHelper.Images.sortCyan24px

            var tableItems: [AnyDifferentiable] = []
            var dictFilmViewModels: Dictionary<Int,FilmsTableCellViewModel> = [:]

            let group = DispatchGroup()
            var lock = os_unfair_lock_s()

            for (index, film) in films.enumerated() {
                group.enter()
                makeOneFilmCell(film: film, index: index) { (oneFilmCellViewModel, index) in
                    os_unfair_lock_lock(&lock)
                    dictFilmViewModels[index] = oneFilmCellViewModel //чтобы одновременного обращения к словарю не было
                    os_unfair_lock_unlock(&lock)
                    group.leave()
                }
            }

            group.notify(queue: DispatchQueue.global()) {
                if dictFilmViewModels.count > 0 {
                    for index in 0...dictFilmViewModels.count - 1 {
                        if let contactCellVM = dictFilmViewModels[index] {
                            tableItems.append(AnyDifferentiable(contactCellVM))
                        }
                    }
                }
                self.presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response(isShow: false))

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.viewController?.displayUpdate(viewModel: FilmsScreenFlow.Update.ViewModel(
                        backViewColor: backColor,
                        navBarBackground: backColor,
                        navBar: navBar,
                        yearButtonText: self.makeFilterButton(year: response.yearForFilterAt),
                        sortIcon: sortIcon,
                        items: tableItems,  
                        isNowFilteringAtSearchOrYearOrSortedDescending: response.isNowFilteringAtSearchOrYearOrSortedDescending,
                        insets: UIEdgeInsets(top: 0,
                                             left: UIHelper.Margins.medium16px,
                                             bottom: 0,
                                             right: UIHelper.Margins.medium16px)))
                }
            }

        }
    }

    func presentAlert(response: FilmsScreenFlow.AlertInfo.Response) {
        let title = GlobalConstants.error
        let text = response.error.localizedDescription
        let buttonTitle = GlobalConstants.ok

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(viewModel: FilmsScreenFlow.AlertInfo.ViewModel(
                title: title,
                text: text,
                buttonTitle: buttonTitle))
        }
    }

    func presentWaitIndicator(response: FilmsScreenFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: FilmsScreenFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
        }
    }

    // MARK: - Private methods

    private func makeOneFilmCell(film: OneFilm,
                                 index: Int,
                                 completion: @escaping (FilmsTableCellViewModel, Int) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {

            var avatarImage: UIImage?

            if let path = film.cachedAvatarPath,
               path != "" {
                // Если файл существует, загружаем изображение из файла
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {// или так доставать data из FileManager.default.contents(atPath: path)
                    avatarImage = UIImage(data: data) ?? UIHelper.Images.imagePlaceholder100px
                }
            } else {
                avatarImage = UIHelper.Images.imagePlaceholder100px
            }

            let genres = film.genres
            let countries = film.countries
            let genresYearCountries = "\(genres.map { $0.genre.lowercased() }.joined(separator: ", ")), \(film.year), \(countries.map { $0.country }.joined(separator: ", "))"

            let filmTitle = NSAttributedString(string: film.nameOriginal ?? "",
                                               attributes: UIHelper.Attributed.whiteInterBold18)

            let subtitle = NSAttributedString(string: genresYearCountries,
                                              attributes: UIHelper.Attributed.grayMedium14)

            let rating = NSAttributedString(string: String(film.ratingKinopoisk ?? 0.0),
                                            attributes: UIHelper.Attributed.cyanSomeBold18)

            let oneFilmCell = FilmsTableCellViewModel(
                filmId: String(film.kinopoiskId),
                filmImage: avatarImage,
                filmTitle: filmTitle,
                subtitle: subtitle,
                rating: rating,
                insets: UIEdgeInsets(top: UIHelper.Margins.medium8px,
                                     left: 0,
                                     bottom: UIHelper.Margins.medium8px,
                                     right: 0))
            completion(oneFilmCell, index)
        }
    }

    private func makeFilterButton(year: Int) -> NSAttributedString {
        let attachmentFilter = NSTextAttachment()
        attachmentFilter.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate) // Используем режим шаблона
        attachmentFilter.bounds = CGRect(x: 0,
                                         y: -UIHelper.Margins.small2px,
                                         width: UIHelper.Margins.large20px,
                                         height: UIHelper.Margins.medium12px)

        let filterAndChevron = NSAttributedString(attachment: attachmentFilter)
        let filterMutableAttributedString = NSMutableAttributedString(
            string: String(year) + " ",
            attributes: UIHelper.Attributed.grayMedium14)
        filterMutableAttributedString.append(filterAndChevron)
        return filterMutableAttributedString
    }

}
