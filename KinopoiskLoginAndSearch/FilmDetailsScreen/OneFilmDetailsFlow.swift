//
//  OneFilmDetailsFlow.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation
import UIKit

enum OneFilmDetailsFlow {

    enum Update {

        struct Request { }

        struct Response {
            let film: DetailsFilm
            let stills: [OneStill]?
        }

        typealias ViewModel = OneFilmDetailsModel.ViewModel
    }


    enum RoutePayload {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnWebLinkTap {

        struct Request {}

        struct Response {
            let webUrl: String
        }

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



