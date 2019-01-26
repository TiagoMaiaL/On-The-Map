//
//  Account.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 25/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The udacity account of the logged user.
struct Account {

    // MARK: Properties

    /// Boolean indicating if the account is registered or not.
    let registered: Bool

    /// The key of the account.
    let key: String

    // MARK: Initializers

    init?(data: [String: AnyObject]) {
        guard let registered = data[UdacityAPIClient.JSONResponseKeys.AccountRegistered] as? Bool else {
            return nil
        }

        guard let key = data[UdacityAPIClient.JSONResponseKeys.AccountKey] as? String else {
            return nil
        }

        self.registered = registered
        self.key = key
    }
}
