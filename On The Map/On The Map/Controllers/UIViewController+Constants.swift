//
//  UIViewController+Constants.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 06/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

extension UIViewController {

    /// The main colors used in the app.
    enum Colors {
        static let UserLocationCellColor = #colorLiteral(red: 0.8105276351, green: 1, blue: 0.6708432227, alpha: 1)
        static let UserLocationMarkerColor = UIColor.green
    }

    /// The segue identifiers used in the app's flow.
    enum SegueIdentifiers {
        static let TabBarController = "Show tab bar controller"
    }
}
