//
//  AppDelegate.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 24/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

    var window: UIWindow?

    // MARK: App Life Cycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let navigationController = window?.rootViewController as? UINavigationController {
            if let loginController = navigationController.topViewController as? LoginViewController {
                loginController.udacityAPIClient = UdacityAPIClient()
            }
        }

        return true
    }
}

