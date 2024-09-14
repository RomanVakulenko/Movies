//
//  AddressBookModels.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import DifferenceKit
import UIKit

enum AddressBookModel {

    enum PickingMode {
        case single, multiple
    }


    struct ViewModel {
        let backViewColor: UIColor
        let navBarBackground: UIColor
        let navBar: CustomNavBar
        let separatorColor: UIColor

        let tabBarTitle: String?
        let tabBarImage: UIImage?
        let tabBarSelectedImage: UIImage?

        let items: [AnyDifferentiable]
    }

}
