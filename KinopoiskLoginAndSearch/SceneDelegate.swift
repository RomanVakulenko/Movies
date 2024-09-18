//
//  SceneDelegate.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//

import UIKit

@available(iOS 13.4, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let loginViewController = LogInRegistrBuilder().getController()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window.rootViewController = navigationController
        self.window = window

        window.makeKeyAndVisible()
    }


}

