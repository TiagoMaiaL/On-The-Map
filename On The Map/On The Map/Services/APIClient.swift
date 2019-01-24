//
//  APIClient.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 24/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Base class containing factory methods for getting configured data tasks for HTTP GET and POST methods.
class APIClient {

    // MARK: Types

    /// A json data that has been deserialized into foundation objects.
    typealias DeserializedJson = [String: AnyObject]

    /// The possible errors passed to the handlers when something goes wrong.
    enum RequestError: Error {
        case connection
        case response(statusCode: Int?)
        case lackingData
        case malformedJson
    }

    /// The HTTP methods used by the API client.
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    // MARK: Properties

    /// The main session used to access any remote resources.
    let session = URLSession.shared

    // MARK: Imperatives

    /// Returns a resumed data task to access a resource using the GET HTTP method.
    /// - Parameters:
    ///     - path: The path of the api to be used.
    ///     - parameters: The parameters to be sent with the request.
    // TODO: Inform each parameter of the completion handler.
    ///     - completionHandler: The completion handler called when the task
    ///                          finishes loading or there's an error.
    /// - Returns: The configured and resumed data task associated with the passed arguments.
    func getConfiguredTaskForGET(
        withAbsolutePath path: String,
        parameters: [String: String],
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
        ) -> URLSessionDataTask? {

        return getConfiguredDataTask(
            forHTTPMethod: .get,
            path: path,
            parameters: parameters,
            body: nil,
            andCompletionHandler: handler
        )
    }

    /// Returns a resumed data task to access a resource using the POST HTTP method.
    /// - Parameters:
    ///     - path: The path of the desired resource.
    ///     - parameters: The parameters to be sent with the request.
    ///     - body: The body json parameters to be send with the request.
    ///     - completionHandler: The completion handler called when the task finishes loading or there's an error.
    /// - Returns: The configured and resumed data task associated with the passed arguments.
    func getConfiguredTaskForPOST(
        withAbsolutePath path: String,
        parameters: [String: String],
        body: [String: String],
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
        ) -> URLSessionDataTask? {

        return getConfiguredDataTask(
            forHTTPMethod: .post,
            path: path,
            parameters: parameters,
            body: body,
            andCompletionHandler: handler
        )
    }

    /// Makes a data task configured for the specific HTTP method and passed parameters.
    ///     - method: The HTTP method associated with the data task.
    ///     - path: The path of the desired resource.
    ///     - parameters: The parameters to be sent with the request.
    ///     - body: Optional body json parameters to be send with the post request.
    ///     - completionHandler: The completion handler called when the task finishes loading or there's an error.
    /// - Returns: The configured and resumed data task associated with the passed arguments.
    private func getConfiguredDataTask(
        forHTTPMethod method: HTTPMethod,
        path: String,
        parameters: [String: String],
        body: [String: String]?,
        andCompletionHandler handler:  @escaping (DeserializedJson?, RequestError?) -> Void
        ) -> URLSessionDataTask? {

        guard let url = getURL(fromPath: path, andParameters: parameters) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        switch method {
        case .post:
            if let body = body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
        default:
            break
        }

        let task = session.dataTask(with: request) { data, response, error in
            let error = self.checkForErrors(inData: data, response: response, andError: error)
            guard error == nil else {
                handler(nil, error)
                return
            }

            guard let json = self.deserializeJson(from: data!) else {
                handler(nil, RequestError.malformedJson)
                return
            }

            handler(json, nil)
        }

        task.resume()

        return task
    }

    /// Mounts the URL instance from the passed path and parameters.
    /// - Parameters:
    ///     - path: The absolute path to the resource.
    ///     - parameters: The parameters to be associated as query items.
    private func getURL(fromPath path: String, andParameters parameters: [String: String]) -> URL? {
        guard let url = URL(string: path) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        return components.url
    }

    /// Checks for errors in the arguments of a data task handler.
    /// - Parameters:
    ///     - data: The data returned from the data task.
    ///     - response: The response associated with the data task request.
    ///     - error: The error associated with the data task, if occurred.
    /// - Returns: An error associated with the arguments or nil.
    private func checkForErrors(inData data: Data?, response: URLResponse?, andError error: Error?) -> RequestError? {
        guard error == nil else {
            return RequestError.connection
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            var status: Int?

            if let httpResponse = response as? HTTPURLResponse {
                status = httpResponse.statusCode
            }

            return RequestError.response(statusCode: status)
        }

        guard data != nil else {
            return RequestError.lackingData
        }

        return nil
    }

    /// Converts raw data into an usable json object.
    /// - Parameter Data: the data to be converted.
    /// - Returns: The DeserializedJson or nil in case of errors while converting.
    private func deserializeJson(from data: Data) -> DeserializedJson? {
        var json: DeserializedJson!
        do {
            json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? DeserializedJson
        } catch {
            return nil
        }

        return json
    }
}
