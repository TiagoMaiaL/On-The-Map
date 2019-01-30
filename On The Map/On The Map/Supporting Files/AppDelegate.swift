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
        if let loginController = window?.rootViewController as? LoginViewController {
            loginController.udacityAPIClient = UdacityAPIClient()
        }

        return true
    }
}

extension UIApplication {

    // MARK: Imperatives

    /// Opens the browser using the passed url text as an address or search.
    /// - Parameter addressText: The address or search to be accessed by the browser.
    func openDefaultBrowser(accessingAddress addressText: String) {
        var addressText = addressText

        // If the address text is not a valid address, embed it in a google search.
        let componentsSplitted = addressText.split(separator: ".")
        if componentsSplitted.count == 1 {
            addressText = "https://www.google.com/search?q=\(componentsSplitted.first!)"
        }

        guard let url = URL(string: addressText) else {
            assertionFailure("Couldn't mount the url.")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
