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
//        client.logIn(withUsername: "", password: "") { account, session, error in
//            guard error == nil else {
//                print("error")
//                return
//            }
//
//            print(account!)
//            print(session!)
//
//            client.getUserInfo(usingUserIdentifier: account!.key) { (user, error) in
//                print(user)
//            }
//        }

        return true
    }
}

