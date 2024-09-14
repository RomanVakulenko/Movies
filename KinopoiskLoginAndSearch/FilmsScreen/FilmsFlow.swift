//
//  AddressBookFlow.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import Foundation

enum AddressBookFlow {

    enum Update {

        struct Request {}

        struct Response {
            let pickedEmailAddresses: [String]
            let isCheckmarkBarIconActive: Bool
            let emailsToShow: [String]
            let allContactsSet: Set<ContactListItem>
            let isMultiPickingMode: Bool
            let doesAllEmailsContainPickedEmails: Bool
            let typeOfSearch: TypeOfSearch
        }

        typealias ViewModel = AddressBookModel.ViewModel
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnBurgerMenuTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnSearchNavBarIconTap {

        struct Request {
            let searchText: String?
            let isSearchBarDisplaying: Bool
        }

        struct Response {
            let searchText: String?
            let isSearchBarDisplaying: Bool
        }

        typealias ViewModel = SearchViewModel
    }

    enum OnCheckmarkBarIconTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }


    enum OnAvatarTap {

        struct Request {
            let onePickedEmailAddress: String
        }

        struct Response {
            let somePickedEmailAddresses: Array<String>
        }

        struct ViewModel {}
    }

    enum OnSelectItem {

        struct Request {
            let id: String
            let onePickedEmailAddress: String
        }

        struct Response {
            let somePickedEmailAddresses: Array<String>
        }

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
