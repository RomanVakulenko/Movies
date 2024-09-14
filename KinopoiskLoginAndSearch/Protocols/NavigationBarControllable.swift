//
//  NavigationBarControllable.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit


protocol NavigationBarControllable: AnyObject {
    func hideNavigationBar(animated: Bool)
    func showNavigationBar(animated: Bool)
    func configureNavigationBar(navBar: CustomNavBar)
    func leftNavBarButtonDidTapped()
    func rightNavBarButtonTapped(index: Int)
}

extension NavigationBarControllable where Self: UIViewController {
    func hideNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func showNavigationBar(animated: Bool = true) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func configureNavigationBar(navBar: CustomNavBar) {
        let backArrow = UIImage(systemName: "arrow.backward") ?? UIImage()
        let backItemColor = UIColor.black

        if let size = self.navigationController?.navigationBar.frame.size {
            self.navigationItem.hidesBackButton = !navBar.isLeftBarButtonEnable

            if navBar.isLeftBarButtonEnable, navBar.isLeftBarButtonCustom == true {
                if let leftBarButtonImage = navBar.leftBarButtonCustom?.image {
                    addLeftBarButtonItem(image: leftBarButtonImage) { [weak self] in
                        self?.leftNavBarButtonDidTapped()
                    }
                }
                navigationItem.leftBarButtonItem?.tintColor = navBar.leftBarButtonCustom?.color
            } else if navBar.isLeftBarButtonEnable, navBar.isLeftBarButtonCustom == false {
                addLeftBarButtonItem(image: backArrow) { [weak self] in
                    self?.leftNavBarButtonDidTapped()
                }
                navigationItem.leftBarButtonItem?.tintColor = backItemColor
            } else {
                self.navigationItem.leftBarButtonItem = nil
            }

            var rightBarButtonItems: [UIBarButtonItem] = []

            if let rightBarButtons = navBar.rightBarButtons {
                for (index, buttonStruct) in rightBarButtons.enumerated() {
                    let customBarButtonItem = CustomBarButtonItem(image: buttonStruct.image, style: .plain) { [weak self] in
                        self?.rightNavBarButtonTapped(index: index)
                    }
                    rightBarButtonItems.insert(customBarButtonItem, at: index) // Вставляем элемент в массив по индексу
                }
            }


            self.navigationItem.rightBarButtonItems = rightBarButtonItems

            let stackView: UIStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            stackView.axis = .vertical
            let titleLabel = UILabel()
            stackView.addArrangedSubview(titleLabel)
            titleLabel.attributedText = navBar.title
            titleLabel.textAlignment = .center
            self.navigationItem.titleView = stackView
        }
    }

    func leftNavBarButtonDidTapped() {}

    func rightNavBarButtonTapped(index: Int) {}

    private func addLeftBarButtonItem(image: UIImage, action: @escaping () -> Void) {
        let barButtonItem = CustomBarButtonItem(image: image, style: .plain) { [weak self] in
            action()
        }
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
}


class CustomBarButtonItem: UIBarButtonItem {
    var customAction: (() -> Void)?

    @objc func performCustomAction() {
        customAction?()
    }

    init(image: UIImage?, style: UIBarButtonItem.Style, customAction: @escaping () -> Void) {
        super.init()
        self.image = image
        self.style = style
        self.target = self
        self.action = #selector(performCustomAction)
        self.customAction = customAction
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
