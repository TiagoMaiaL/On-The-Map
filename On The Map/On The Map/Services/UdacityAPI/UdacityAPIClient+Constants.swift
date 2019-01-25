//
//  UdacityAPIClient+Constants.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 25/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension UdacityAPIClient {

    // MARK: Constants

    enum API {
        static let Scheme = "https"
        static let Host = "onthemap-api.udacity.com"
        static let Path = "v1"
    }

    enum URLKeys {
        static let UserID = "user_id"
    }

    enum Methods {
        static let Session = "session"
        static let User = "user/{\(URLKeys.UserID)}"
    }
}
