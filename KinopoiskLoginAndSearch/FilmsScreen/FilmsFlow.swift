//
//  FilmsScreenFlow.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

enum FilmsScreenFlow {

    enum Update {

        struct Request {}

        struct Response {
            let isNowFilteringAtSearchOrYearOrSortedDescending: Bool
            let filmsSortedFiltered: [OneFilm]?
            let yearForFilterAt: Int
        }

        typealias ViewModel = FilmsModel.ViewModel
    }

    enum UpdateSearch {

        struct Request {}

        struct Response {}

        typealias ViewModel = SearchViewModel
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnSortIconTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }


    enum OnLoadRequest {

        struct Request {
            let isRefreshRequested: Bool
        }

        struct Response {}

        struct ViewModel {}
    }

    enum OnSearchBarGlassIconTap {

        struct Request {
            let searchText: String?
        }

        struct Response {}

        typealias ViewModel = SearchViewModel
    }

    enum OnLogOffBarItemTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnYearButtonTap {

        struct Request {
            let year: Int
        }

        struct Response {}

        struct ViewModel {}
    }

    enum OnSelectItem {

        struct Request {
            let id: String
        }

        struct Response {}

        struct ViewModel {}
    }

    enum RoutePayload {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnWaitIndicator {

        struct Request {}

        struct Response {
            let isShow: Bool
        }

        struct ViewModel {
            let isShow: Bool
        }
    }

    enum AlertInfo {

        struct Request {}

        struct Response {
            let error: Error
        }

        struct ViewModel {
            let title: String?
            let text: String?
            let buttonTitle: String?
        }
    }
}
