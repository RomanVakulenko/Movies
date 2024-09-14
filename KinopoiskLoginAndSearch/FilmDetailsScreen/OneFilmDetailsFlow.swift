//
//  OneEmailDetailsFlow.swift
//  SGTS
//
//  Created by Roman Vakulenko on 22.04.2024.
//

import Foundation
import UIKit

enum OneEmailDetailsFlow {

    enum Update {

        struct Request { }

        struct Response {
            let emailModelWithNeededProperties: EmailMessageWithNeededProperties
            let shouldUpdateButtons: Bool
            let htmlInlineAttachments: [AttachmentModel]
            let messageTypeFromSideMenu: TabBarManager.MessageType
        }

        typealias ViewModel = OneEmailDetailsModel.ViewModel
    }

    enum OnTrashNavBarIcon {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum RoutePayload {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnChevronTapped {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }


    enum OnAttachedFileOrImageTapped {

        struct Request {
            var fotoViewModel: FotoCellViewModel?
            var cloudEmailViewModel: CloudEmailAttachmentViewModel?
        }

        struct Response { }

        struct ViewModel { }
    }

    enum OnDownloadIconOrToSaveAttachedFile {

        struct Request {
            var fotoViewModel: FotoCellViewModel?
        }

        struct Response {}

        struct ViewModel {}
    }

    enum OnQuattroIcon {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnEnvelopNavBarButton {
        
        struct Request {}

        struct Response {}

        struct ViewModel {}
    }


    enum OnReplyButton {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnReplyToAllButton {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnForwardButton {

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



