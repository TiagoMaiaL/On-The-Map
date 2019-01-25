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

    /// The constants used to generate an url to access a resource in the API.
    enum API {
        static let Scheme = "https"
        static let Host = "onthemap-api.udacity.com"
        static let Path = "/v1"
    }

    /// The keys to be replaced with real values in the API methods to be called.
    enum URLKeys {
        static let UserID = "user_id"
    }

    /// The methods used in the API.
    enum Methods {
        static let Session = "session"
        static let User = "users/{\(URLKeys.UserID)}"
    }

    /// The keys to access the data in the returned json data.
    enum JSONResponseKeys {
        static let Account = "account"
        static let AccountKey = "key"
        static let Session = "session"
        static let SessionID = "id"
        static let User = "user"
        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
    }
}
