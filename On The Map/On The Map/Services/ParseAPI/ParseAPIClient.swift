//
//  ParseAPIClient.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 28/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The Client used to access the Parse API.
class ParseAPIClient: APIClient, ParseAPIClientProtocol {

    // MARK: Properties

    var studentLocations: [StudentInformation]?

    /// The base url for making requests to the Parse API.
    private lazy var baseURL: URL = {
        guard let url = mountBaseURL(usingScheme: API.Scheme, host: API.Host, andPath: API.Path) else {
            assertionFailure("Couldn't mount the url.")
            return URL(string: "")!
        }
        return url
    }()

    // MARK: Initializers

    override init() {
        super.init()

        requiredAPIHeaders = [
            "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        ]
    }

    // MARK: Imperatives

    func fetchStudentLocations(
        withLimit limit: Int,
        skippingPages pagesToSkip: Int,
        andUsingCompletionHandler handler: @escaping ([StudentInformation]?, APIClient.RequestError?) -> Void
        ) {
        let fetchUrl = baseURL.appendingPathComponent(Methods.StudentLocation)
        let parameters = [ParameterKeys.Limit: String(limit), ParameterKeys.Page: String(pagesToSkip * limit)]
        _ = getConfiguredTaskForGET(withAbsolutePath: fetchUrl.absoluteString, parameters: parameters) { json, error in
            guard error == nil else {
                handler(nil, error!)
                return
            }

            let json = json!

            guard let results = json[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                handler(nil, RequestError.malformedJson)
                return
            }

            let locations = results.compactMap { StudentInformation(informationData: $0) }

            assert(!locations.isEmpty, "The mapped locations mustn't be empty.")

            self.studentLocations = locations
            handler(locations, nil)
        }
    }

    /// Fetches the specific student location by the uniqueKey.
    /// - Parameters:
    ///     - uniqueKey: the unique key of the student information to be fetched.
    ///     - handler: the closure called when the request finishes, with the found value, or an error.
    func fetchStudentLocation(
        byUsingUniqueKey key: String,
        andCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
        ) {
        let fetchUrl = baseURL.appendingPathComponent(Methods.StudentLocation)
        let parameters = [ParameterKeys.WhereQuery: "{\"\(JSONResponseKeys.InformationKey)\" : \"\(key)\"}"]
        _ = getConfiguredTaskForGET(withAbsolutePath: fetchUrl.absoluteString, parameters: parameters)  { json, error in
            guard error == nil, let json = json else {
                handler(nil, error!)
                return
            }

            guard let results = json[JSONResponseKeys.Results] as? [[String: AnyObject]], !results.isEmpty else {
                handler(nil, APIClient.RequestError.malformedJson)
                return
            }

            guard let fetchedInformation = StudentInformation(informationData: results.first!) else {
                handler(nil, APIClient.RequestError.malformedJson)
                return
            }

            handler(fetchedInformation, nil)
        }
    }

    func createStudentLocation(
        _ information: StudentInformation,
        withCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
        ) {
        guard let jsonData = getJsonRepresentation(ofStudentInformation: information) else {
            assertionFailure("Couldn't get the student information json body data.")
            handler(nil, APIClient.RequestError.malformedJsonBody)
            return
        }

        _ = getConfiguredTaskForPOST(
            withAbsolutePath: baseURL.appendingPathComponent(Methods.StudentLocation).absoluteString,
            parameters: [:],
            jsonBody: jsonData
        ) { json, error in
            guard error == nil, json != nil else {
                handler(nil, error!)
                return
            }

            handler(information, nil)
        }
    }

    func updateStudentLocation(
        _ information: StudentInformation,
        withCompletionHandler handler: (StudentInformation?, APIClient.RequestError?) -> Void
        ) {

    }

    /// Gets a json string from the passed student information.
    /// - Parameter studentInformation: the information used to create the json string.
    /// - Returns: the information as a json data.
    private func getJsonRepresentation(ofStudentInformation studentInformation: StudentInformation) -> Data? {
        let jsonDictionary: [String: Any] = [
            JSONResponseKeys.FirstName: studentInformation.firstName,
            JSONResponseKeys.LastName: studentInformation.lastName,
            JSONResponseKeys.MapTextReference: studentInformation.mapTextReference,
            JSONResponseKeys.Latitude: studentInformation.latitude,
            JSONResponseKeys.Longitude: studentInformation.longitude,
            JSONResponseKeys.MediaUrl: studentInformation.mediaUrl.absoluteString,
            JSONResponseKeys.InformationKey: studentInformation.key
        ]
        return try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
    }
}
