//
//  LogInRegistrFlow.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import Foundation

enum LogInRegistrFlow {

    enum Update {

        struct Request {}
        
        struct Response {}

        typealias ViewModel = LogInRegistrModel.ViewModel
    }

    enum RoutePayload {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnEnterButtonTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }


    enum OnSelectItem {

        struct Request {
            let id: AnyHashable
            let selectedString: String?
        }

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
            let firstButtonTitle: String?
        }
    }
}
