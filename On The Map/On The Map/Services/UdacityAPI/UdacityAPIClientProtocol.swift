//
//  UdacityAPIClientProtocol.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 27/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Protocol defining the main interface of the udacity api client.
protocol UdacityAPIClientProtocol {

    // MARK: Parameters

    /// The session returned when the user logs in.
    var userSession: Session? { get }

    /// The account returned when the user logs in.
    var userAccount: Account? { get }

    /// The current logged user.
    var user: User? { get }

    // MARK: Imperatives

    /// Logs the user in with the passed parameters.
    /// - Parameters:
    ///     - username: the name of the user.
    ///     - password: the password of the user.
    ///     - completionHandler: the closure called when the login request returns.
    func logIn(
        withUsername username: String,
        password: String,
        andCompletionHandler handler: @escaping (Account?, Session?, APIClient.RequestError?) -> Void
    )

    /// Logs the user out.
    /// - Parameter completionHandler: the closure called when the logout request returns.
    func logOut(withCompletionHandler handler: @escaping (Bool, APIClient.RequestError?) -> Void)

    /// Gets the user info using the passed user identifier.
    /// - Parameters:
    ///     - userID: the identifier of the user to get the details from.
    ///     - completionHandler: the closure called when the details request returns.
    func getUserInfo(
        usingUserIdentifier userID: String,
        andCompletionHandler handler: @escaping (User?, APIClient.RequestError?) -> Void
    )
}
