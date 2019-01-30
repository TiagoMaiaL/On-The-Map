//
//  UdacityAPIClient.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 24/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The API Client used to connect with the Udacity auth API.
final class UdacityAPIClient: APIClient, UdacityAPIClientProtocol {

    // MARK: Parameters

    /// The session returned when the user logs in.
    private(set) var userSession: Session?

    /// The account returned when the user logs in.
    private(set) var userAccount: Account?

    /// The current logged user.
    private(set) var user: User?

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

    func logIn(
        withUsername username: String,
        password: String,
        andCompletionHandler handler: @escaping (Account?, Session?, APIClient.RequestError?) -> Void
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

            guard let accountData = json[JSONResponseKeys.Account] as? [String: AnyObject],
                let account = Account(data: accountData) else {
                    handler(nil, nil, RequestError.malformedJson)
                    return
            }

            guard let sessionData = json[JSONResponseKeys.Session] as? [String: AnyObject],
                let session = Session(data: sessionData) else {
                    handler(nil, nil, RequestError.malformedJson)
                    return
            }

            self.userAccount = account
            self.userSession = session
            handler(account, session, nil)
        }
    }

    func logOut(withCompletionHandler handler: @escaping (Bool, APIClient.RequestError?) -> Void) {
        _ = getConfiguredTaskForDELETE(
            withAbsolutePath: baseURL.appendingPathComponent(Methods.Session).absoluteString,
            parameters: [:]
        ) { json, error in
            guard error == nil else {
                handler(false, error)
                return
            }

            handler(true, nil)
        }
    }

    func getUserInfo(
        usingUserIdentifier userID: String,
        andCompletionHandler handler: @escaping (User?, APIClient.RequestError?) -> Void
    ) {
        let url = baseURL.appendingPathComponent(Methods.User.byReplacingKey(URLKeys.UserID, withValue: userID))
        _ = getConfiguredTaskForGET(withAbsolutePath: url.absoluteString, parameters: [:]) { json, error in
            guard error == nil else {
                handler(nil, error!)
                return
            }

            guard let user = User(userData: json!) else {
                handler(nil, RequestError.malformedJson)
                return
            }

            self.user = user
            handler(user, nil)
        }
    }
}
