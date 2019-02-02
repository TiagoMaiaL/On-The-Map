//
//  User.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 25/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The user logged in the Udacity API.
struct User {

    // MARK: Properties

    /// The first name of the user.
    let firstName: String

    /// The last name of the user.
    let lastName: String

    /// The user key.
    let key: String

    // MARK: Initializers

    init?(userData: [String: AnyObject]) {
        guard let firstName = userData[UdacityAPIClient.JSONResponseKeys.UserFirstName] as? String,
            let lastName = userData[UdacityAPIClient.JSONResponseKeys.UserLastName] as? String else {
                return nil
        }

        self.firstName = firstName
        self.lastName = lastName

        guard let key = userData[UdacityAPIClient.JSONResponseKeys.UserKey] as? String else {
            return nil
        }

        self.key = key
    }
}
