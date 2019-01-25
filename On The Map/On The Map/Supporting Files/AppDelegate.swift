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
        let client = UdacityAPIClient()
        // TODO: Inject the API client in the controller.
//        client.logIn(withUsername: "", password: "") { accountKey, sessionID, error in
//            guard error == nil else {
//                print("error")
//                return
//            }
//
//            print("account key: " + accountKey!)
//            print("session id: " + sessionID!)
//
//            client.getUserInfo(usingUserIdentifier: accountKey!) { (userData, error) in
//                print(userData)
//            }
//        }

        return true
    }
}

