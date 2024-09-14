//
//  AddressBookPresenter.swift
//  SGTS
//
//  Created by Roman Vakulenko on 29.05.2024.
//

import UIKit
import DifferenceKit
import SnapKit

protocol AddressBookPresentationLogic {
    func presentSearchBar(response: AddressBookFlow.OnSearchNavBarIconTap.Response)
    func presentUpdate(response: AddressBookFlow.Update.Response)
    func presentWaitIndicator(response: AddressBookFlow.OnWaitIndicator.Response)
    func presentAlert(response: AddressBookFlow.AlertInfo.Response)

    func presentRouteToSideMenu(response: AddressBookFlow.RoutePayload.Response)
    func presentRouteBackToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response)
    func presentRouteToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response)
    func presentRouteToOneContactDetails(response: AddressBookFlow.RoutePayload.Response)
}


final class AddressBookPresenter: AddressBookPresentationLogic {

    enum Constants {
        static let mainImageWidthHeight: CGFloat = 45
    }

    // MARK: - Public properties

    weak var viewController: AddressBookDisplayLogic?

    // MARK: - Public methods

    func presentRouteToOneContactDetails(response: AddressBookFlow.RoutePayload.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToOneContactDetails(viewModel: AddressBookFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteBackToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteBackToNewEmailCreateScreen(viewModel: AddressBookFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToNewEmailCreateScreen(response: AddressBookFlow.OnSelectItem.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToNewEmailCreateScreen(viewModel: AddressBookFlow.RoutePayload.ViewModel())
        }
    }

    func presentRouteToSideMenu(response: AddressBookFlow.RoutePayload.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayRouteToSideMenu(viewModel: AddressBookFlow.RoutePayload.ViewModel())
        }
    }

    func presentSearchBar(response: AddressBookFlow.OnSearchNavBarIconTap.Response) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
            let separatorColor = Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD

            let searchBarAttributedPlaceholder = NSAttributedString(string: getString(.searchViewPlaceholder), attributes: Theme.shared.isLight ? UIHelper.Attributed.grayLRobotoRegular16 : UIHelper.Attributed.grayRegularD2RobotoRegular16)

            let searchText = response.searchText ?? ""
            let searchTextColor = Theme.shared.isLight ? UIHelper.Color.blackMiddleL : UIHelper.Color.whiteStrong
            let searchIcon = Theme.shared.isLight ? UIHelper.Image.searchIcon24x24L : UIHelper.Image.searchIcon24x24D

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.toggleSearchBar(viewModel: AddressBookFlow.OnSearchNavBarIconTap.ViewModel(
                    id: 11,
                    backColor: backColor,
                    isSearchBarDisplaying: response.isSearchBarDisplaying,
                    searchBarAttributedPlaceholder: searchBarAttributedPlaceholder,
                    searchText: searchText,
                    searchIcon: searchIcon,
                    searchTextColor: searchTextColor,
                    separatorColor: separatorColor,
                    insets: .zero)
                )
            }
        }
    }


    func presentUpdate(response: AddressBookFlow.Update.Response) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let backColor = Theme.shared.isLight ? UIHelper.Color.white : UIHelper.Color.blackLightD
            let separatorColor = Theme.shared.isLight ? UIHelper.Color.grayLightL : UIHelper.Color.grayStrongD

            var tableItems: [AnyDifferentiable] = []

            var textForScreenTitle = getString(.searchContacts)
            if response.pickedEmailAddresses.count > 0 && response.typeOfSearch == .server {
                textForScreenTitle = String(response.pickedEmailAddresses.count)
            } else if response.typeOfSearch == .database  {
                textForScreenTitle = getString(.addressBookScreenTitle)
            }
            let screenTitle = NSAttributedString(
                string: textForScreenTitle,
                attributes: Theme.shared.isLight ? UIHelper.Attributed.blackStrongLRobotoMedium18 : UIHelper.Attributed.whiteStrongRobotoMedium18)

            var checkmarkNavBarIcon: NavBarButton
            var navBar: CustomNavBar

            var tabBarTitle: String?
            var tabBarImage: UIImage?
            var tabBarSelectedImage: UIImage?

            switch response.typeOfSearch {
            case .database:
                if response.isCheckmarkBarIconActive {
                    checkmarkNavBarIcon = NavBarButton(image: UIHelper.Image.addressBookGreenCheckmarkNavBarIcon24x24Both)
                } else {
                    checkmarkNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.addressBookCheckmarkNavBarIcon24x24L : UIHelper.Image.addressBookCheckmarkNavBarIcon24x24D)
                }
                let searchNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.searchIcon24x24L : UIHelper.Image.searchIcon24x24D)
                navBar = CustomNavBar(title: screenTitle,
                                      isLeftBarButtonEnable: true,
                                      isLeftBarButtonCustom: false,
                                      leftBarButtonCustom: nil,
                                      rightBarButtons: [checkmarkNavBarIcon, searchNavBarIcon])

            case .server: //sandwich
                let sandwichNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.emailSandwichL : UIHelper.Image.emailSandwichD)

                var planeNavBarIcon: NavBarButton
                if response.isMultiPickingMode == true {
                    planeNavBarIcon = NavBarButton(image: Theme.shared.isLight ? UIHelper.Image.newEmailCreatePlaneNavBarIconL : UIHelper.Image.newEmailCreatePlaneNavBarIconD)
                } else {
                    planeNavBarIcon = NavBarButton(image: nil)
                }
                navBar = CustomNavBar(title: screenTitle,
                                      isLeftBarButtonEnable: true,
                                      isLeftBarButtonCustom: true,
                                      leftBarButtonCustom: sandwichNavBarIcon,
                                      rightBarButtons: [planeNavBarIcon])

                tabBarTitle = TabBarManager.makeTitleImageAndSelectedImageForTabItem(messageType: .searchContactsAtServer).0
                tabBarImage = TabBarManager.makeTitleImageAndSelectedImageForTabItem(messageType: .searchContactsAtServer).1
                tabBarSelectedImage = TabBarManager.makeTitleImageAndSelectedImageForTabItem(messageType: .searchContactsAtServer).2
            }


            if response.emailsToShow.isEmpty {
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.displayUpdate(viewModel: AddressBookFlow.Update.ViewModel(
                        backViewColor: backColor,
                        navBarBackground: backColor,
                        navBar: navBar,
                        separatorColor: separatorColor,
                        tabBarTitle: tabBarTitle,
                        tabBarImage: tabBarImage,
                        tabBarSelectedImage: tabBarSelectedImage,
                        items: tableItems))
                }
            } else {
                var dictEmailMessage: Dictionary<Int,ContactNameAndAddressCellViewModel> = [:]

                let group = DispatchGroup()
                var lock = os_unfair_lock_s()

                for (index, emailToShow) in response.emailsToShow.enumerated() {
                    group.enter()
                    makeOneAddressAndNameCell(response: response,
                                              emailToShow: emailToShow,
                                              backViewColor: backColor,
                                              index: index) { (contactNameAndAddressCellViewModel, index) in
                        os_unfair_lock_lock(&lock)
                        dictEmailMessage[index] = contactNameAndAddressCellViewModel //чтобы одновременного обращения к словарю не было
                        os_unfair_lock_unlock(&lock)
                        group.leave()
                    }
                }

                group.notify(queue: DispatchQueue.global()) {
                    for index in 0...dictEmailMessage.count - 1 {
                        if let contactCellVM = dictEmailMessage[index] {
                            tableItems.append(AnyDifferentiable(contactCellVM))
                        }
                    }
                    self.presentWaitIndicator(response: AddressBookFlow.OnWaitIndicator.Response(isShow: false))
                    DispatchQueue.main.async { [weak self] in
                        self?.viewController?.displayUpdate(viewModel: AddressBookFlow.Update.ViewModel(
                            backViewColor: backColor,
                            navBarBackground: backColor,
                            navBar: navBar,
                            separatorColor: separatorColor,
                            tabBarTitle: tabBarTitle,
                            tabBarImage: tabBarImage,
                            tabBarSelectedImage: tabBarSelectedImage,
                            items: tableItems))
                    }
                }
            }
        }
    }

    func presentAlert(response: AddressBookFlow.AlertInfo.Response) {
        let title = getString(.error)
        let text = response.error.localizedDescription
        let buttonTitle = getString(.closeAction)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(viewModel: AddressBookFlow.AlertInfo.ViewModel(
                title: title,
                text: text,
                buttonTitle: buttonTitle))
        }
    }

    func presentWaitIndicator(response: AddressBookFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: AddressBookFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
        }
    }

    // MARK: - Private methods

    private func makeOneAddressAndNameCell(response: AddressBookFlow.Update.Response,
                                           emailToShow: String,
                                           backViewColor: UIColor,
                                           index: Int,
                                           completion: @escaping (ContactNameAndAddressCellViewModel, Int) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var avatarImage = UIImage()

            guard let contact = response.allContactsSet.first(where: { $0.email == emailToShow }) else { return } //если делать здесь $0.email.lowercased(), а в интеракторе не приводить к нижнему регистру, то не красится в галочку при долгом нажатии

            if response.doesAllEmailsContainPickedEmails == false && response.isMultiPickingMode == false {
                let semaphore = DispatchSemaphore(value: 0) //кол-во потоков(0), кот. имеют доступ к ресурсу
                if let image = UIImage(contentsOfFile: contact.avatar) {
                    avatarImage = image //то есть пока не вызван signal() код ниже wait не будет выполняться
                    semaphore.signal() //Increment the counting semaphore (имеет доступ 1 поток)
                } else {
                    let char = String(contact.sname.prefix(1))
                    let backColorOfImage = Alphabet.colorOfFirstLetter(in: contact.fname)

                    ImageManager.createIcon(for: char,
                                            backCellViewColor: backViewColor,
                                            backColorOfImage: backColorOfImage,
                                            width: Constants.mainImageWidthHeight,
                                            height: Constants.mainImageWidthHeight) { image in
                        avatarImage = image ?? UIImage() //то есть пока не вызван signal() код ниже wait не будет выполняться
                        semaphore.signal()
                    }
                }
                semaphore.wait() //Decrement the counting semaphore (доступ для 0 потоков)
            } else if response.pickedEmailAddresses.contains(contact.email) {
                avatarImage = UIHelper.Image.emailPickedScreenAvatarBoth
            } else {
                avatarImage = Theme.shared.isLight ? UIHelper.Image.notPickedAvatarL : UIHelper.Image.notPickedAvatarD
            }

            let backCellViewColor: UIColor
            if response.pickedEmailAddresses.contains(contact.email) {
                backCellViewColor = Theme.shared.isLight ? UIHelper.Color.almostWhiteL2 : UIHelper.Color.almostBlackD2
            } else {
                backCellViewColor = backViewColor
            }

            let name = NSAttributedString(string: contact.cn, attributes: Theme.shared.isLight ? UIHelper.Attributed.blackMiddleLRobotoSemibold17 : UIHelper.Attributed.whiteStrongRobotoSemibold17)

            let emailAddress = NSAttributedString(string: contact.email, attributes: Theme.shared.isLight ? UIHelper.Attributed.grayAlpha06RobotoRegular14 : UIHelper.Attributed.whiteDarkDRobotoRegular14)

            let chevron = Theme.shared.isLight ? UIHelper.Image.chevronRightL : UIHelper.Image.chevronRightD

            let oneAddressAndNameCell = ContactNameAndAddressCellViewModel(
                id: contact.uid,
                cellBackColor: backCellViewColor,
                avatarImage: avatarImage,
                name: name,
                email: emailAddress,
                chevron: chevron,
                insets: UIEdgeInsets(top: UIHelper.Margins.medium16px,
                                     left: UIHelper.Margins.medium16px,
                                     bottom: UIHelper.Margins.medium16px,
                                     right: 0),
                separatorInset: .zero
            )
            completion(oneAddressAndNameCell, index)
        }
    }
}
