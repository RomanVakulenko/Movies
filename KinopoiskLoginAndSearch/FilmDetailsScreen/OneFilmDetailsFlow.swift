//
//  OneFilmDetailsFlow.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import UIKit

enum OneFilmDetailsFlow {

    enum UpdateAllButStills {

        struct Request { }

        struct Response {
            let film: DetailsFilm
        }

        typealias ViewModel = OneFilmDetailsModel.ViewModel
    }

    enum UpdateStills {

        struct Request { }

        struct Response {
            let stills: [OneStill]?
        }

        typealias ViewModel = StillsViewModel
    }


    enum OnLoadRequest {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnChevronTapped {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum RoutePayload {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnWebLinkTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnWaitIndicator {

        struct Request {}

        struct Response {
            let isShow: Bool
            let type: SpinnerPlace
        }

        struct ViewModel {
            let isShow: Bool
            let type: SpinnerPlace
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



