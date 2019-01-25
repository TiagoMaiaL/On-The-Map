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

    /// The base URL used for the requests in the API.
    private lazy var baseURL: URL = {
        guard let url = mountBaseURL(usingScheme: API.Scheme, host: API.Host, andPath: API.Path) else {
            assertionFailure("Couldn't mount the base url.")
            return URL(string: "")!
        }

        return url
    }()

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
    func logIn(
        withUsername username: String,
        password: String,
        andCompletionHandler handler: @escaping (String?, String?, Error?) -> ()
        ) {
        let body = """
        {
            "udacity": {
                "username": "\(username)",
                "password": "\(password)"
            }
        }
"""

        _ = getConfiguredTaskForPOST(
            withAbsolutePath: baseURL.appendingPathComponent(Methods.Session).absoluteString,
            parameters: [:],
            jsonBody: body
        ) { json, error in
            guard error == nil else {
                handler(nil, nil, error)
                return
            }

            let json = json!

            guard let account = json[JSONResponseKeys.Account] as? [String: String] else {
                handler(nil, nil, RequestError.malformedJson)
                return
            }

            guard let accountKey = account[JSONResponseKeys.AccountKey] else {
                handler(nil, nil, RequestError.malformedJson)
                return
            }

            guard let session = json[JSONResponseKeys.Session] as? [String: String] else {
                handler(nil, nil, RequestError.malformedJson)
                return
            }

            guard let sessionID = session[JSONResponseKeys.SessionID] else {
                handler(nil, nil, RequestError.malformedJson)
                return
            }

            self.accountKey = accountKey
            self.sessionID = sessionID
            handler(accountKey, sessionID, nil)
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
