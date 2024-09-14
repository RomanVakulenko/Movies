//
//  AddressBookRouter.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import UIKit

protocol AddressBookRoutingLogic {
    func routeBackToNewEmailCreateScreen()
    func routeToNewEmailCreateScreen()
    func routeToSideMenu()
    func routeToOneContactDetails()
}

protocol AddressBookDataPassing {
    var dataStore: AddressBookDataStore? { get }
}

protocol AddressBookGetAdressesDelegate: AnyObject {
    func getEmailAdresses(pickedEmailAdresses: [String])
}

final class AddressBookRouter: AddressBookRoutingLogic, AddressBookDataPassing {
    
    weak var viewController: AddressBookController?
    weak var dataStore: AddressBookDataStore?
    
    
    // MARK: - Public methods
    
    func routeToSideMenu() {
        let sideMenuController = SideMenuBuilder().getController()
        
        sideMenuController.modalPresentationStyle = .custom
        sideMenuController.modalTransitionStyle = .coverVertical
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.present(sideMenuController, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.viewController?.tabBarController?.tabBar.layer.zPosition = -1
                self?.viewController?.tabBarController?.tabBar.isUserInteractionEnabled = false
            }
        }
    }
    
    func routeBackToNewEmailCreateScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: false)
        }
    }
    
    func routeToNewEmailCreateScreen() {
        if let addressesDelegate = viewController?.delegate,
           let somePickedEmailAddresses = dataStore?.pickedEmailAddresses{
            addressesDelegate.getEmailAdresses(
                pickedEmailAdresses: somePickedEmailAddresses)
        }
        switch dataStore?.typeOfSearch {
        case .database:
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.navigationController?.popViewController(animated: false)
            }
        case .server:
            let newEmailController = NewEmailCreateBuilder().getControllerWith(
                messageModel: nil,
                pickedEmailAddresses: dataStore?.pickedEmailAddresses,
                emailType: .newEmail)
            
            DispatchQueue.main.async { [weak self] in
                if let navigationController = self?.viewController?.navigationController {
                    TabBarManager.hideAndDisableTabBarFor(navController: navigationController)
                    navigationController.pushViewController(newEmailController, animated: true)
                }
            }
        case nil:
            break
        }
        
    }
    
    func routeToOneContactDetails() {
        if let contactStruct = dataStore?.oneContactInfoForOpenDetails,
           let addressBookVC = viewController,
           let isMultiPickingMode = dataStore?.isMultiPickingMode {
            
            let oneContactVC = OneContactDetailsBuilder().getControllerWith(
                contactStruct: contactStruct,
                delegate: addressBookVC,
                isMultiPickingMode: isMultiPickingMode)
            
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.navigationController?.pushViewController(oneContactVC, animated: true)
            }
        }
    }
    
}
