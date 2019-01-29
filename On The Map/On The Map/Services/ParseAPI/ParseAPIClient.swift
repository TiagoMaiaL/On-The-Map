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
}
