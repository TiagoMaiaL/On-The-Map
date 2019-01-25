//
//  UdacityAPIClient.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 24/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The API Client used to connect with the Udacity auth API.
final class UdacityAPIClient: APIClient {

    // MARK: Parameters

    /// The session identifier returned when the user logs in.
    private(set) var sessionID: String?

    /// The account key returned when the user logs in.
    private(set) var accountKey: String?

    // MARK: Initializers

    override init() {
        super.init()

        /// Always strip the first 5 chars from the returned json, this is a security check required by the API.
        preHandleData = { $0.subdata(in: 5..<$0.count) }
    }

    // MARK: Imperatives

    /// Logs the user in with the passed parameters.
    /// - Parameters:
    ///     - username: the name of the user.
    ///     - password: the password of the user.
    ///     - completionHandler: the closure called when the login request returns.
    func logIn(withUsername username: String, andPassword password: String) {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = API.Path

        guard let url = components.url?.appendingPathComponent(Methods.Session) else {
            assertionFailure("Failed to mount the URL.")
            return
        }

        let body = """
        {
            "udacity": {
                "username": "\(username)",
                "password": "\(password)"
            }
        }
"""

        _ = getConfiguredTaskForPOST(
            withAbsolutePath: url.absoluteString,
            parameters: [:],
            jsonBody: body
        ) { json, error in
            guard error == nil else {
                return
            }

            print(json!)
        }
    }

    /// Logs the user out.
    /// - Parameter completionHandler: the closure called when the logout request returns.
    func logOut() {
        // TODO:
    }

    /// Gets the user info using the passed user identifier.
    /// - Parameters:
    ///     - userID: the identifier of the user to get the details from.
    ///     - completionHandler: the closure called when the details request returns.
    func getUserInfo(usingUserIdentifier userID: String) {
        // TODO:
    }
}
