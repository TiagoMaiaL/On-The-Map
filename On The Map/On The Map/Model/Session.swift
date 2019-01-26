//
//  Session.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 25/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The udacity session of the logged user.
struct Session {

    // MARK: Properties

    /// The identifier of the session.
    let identifier: String

    /// The expiration date of the session.
    let expiration: Date

    // MARK: Initializers

    init?(data: [String: AnyObject]) {
        guard let identifier = data[UdacityAPIClient.JSONResponseKeys.SessionID] as? String else {
            return nil
        }

        guard let expiration = data[UdacityAPIClient.JSONResponseKeys.SessionExpiration] as? Date else {
            return nil
        }

        self.identifier = identifier
        self.expiration = expiration
    }
}
