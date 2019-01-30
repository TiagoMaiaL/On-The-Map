//
//  APIClient.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 24/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UIKit

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
        case delete = "DELETE"
    }

    // MARK: Properties

    /// The main session used to access any remote resources.
    let session = URLSession.shared

    /// The closure in charge of making any pre handling of the returned data from the endpoint methods.
    /// - Note: Assign a closure to this property if it's necessary to any pre-handling of the data returned.
    var preHandleData: ((Data) -> Data)?

    /// Any request headers required to use the API endpoints.
    var requiredAPIHeaders: [String: String]?

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

        let task = getConfiguredDataTask(
            forHTTPMethod: .get,
            path: path,
            parameters: parameters,
            jsonBody: nil,
            completionHandler: handler
        )

        return task
    }

    /// Returns a resumed data task to access a resource using the POST HTTP method.
    /// - Parameters:
    ///     - path: The path of the desired resource.
    ///     - parameters: The parameters to be sent with the request.
    ///     - jsonBody: The body json parameters to be sent with the request.
    ///     - completionHandler: The completion handler called when the task finishes loading or there's an error.
    /// - Returns: The configured and resumed data task associated with the passed arguments.
    func getConfiguredTaskForPOST(
        withAbsolutePath path: String,
        parameters: [String: String],
        jsonBody: String,
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
        ) -> URLSessionDataTask? {

        let task = getConfiguredDataTask(
            forHTTPMethod: .post,
            path: path,
            parameters: parameters,
            jsonBody: jsonBody,
            completionHandler: handler
        )

        return task
    }

    /// Returns a resumed data task to delete a resource using the DELETE HTTP method.
    /// - Parameters:
    ///     - path: The path of the resource to be deleted.
    ///     - parameters: The parameters to be sent with the request.
    ///     - completionHandler: The completion handler called when the task finishes or there's an error.
    /// - Returns: The configured and resumed data task associated with the passed arguments.
    func getConfiguredTaskForDELETE(
        withAbsolutePath path: String,
        parameters: [String: String],
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
        ) -> URLSessionDataTask? {

        let task = getConfiguredDataTask(
            forHTTPMethod: .delete,
            path: path,
            parameters: parameters,
            jsonBody: nil,
            completionHandler: handler,
            andUsingRequestPreHandler: { urlRequest in
                var urlRequest = urlRequest

                if let xsrfCookie = HTTPCookieStorage.shared.cookies?.filter({ $0.name == "XSRF-TOKEN" }).first {
                    urlRequest.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
                }

                return urlRequest
            }
        )

        return task
    }

    /// Makes a data task configured for the specific HTTP method and passed parameters.
    /// - Parameters:
    ///     - method: The HTTP method associated with the data task.
    ///     - path: The path of the desired resource.
    ///     - parameters: The parameters to be sent with the request.
    ///     - jsonBody: Optional json body parameters to be sent with the post request.
    ///     - completionHandler: The completion handler called when the task finishes loading or there's an error.
    ///     - requestPreHandler: The closure in charge of making any custom configurations to the url request
    ///                          before initiating the data task.
    /// - Returns: The configured and resumed data task associated with the passed arguments.
    private func getConfiguredDataTask(
        forHTTPMethod method: HTTPMethod,
        path: String,
        parameters: [String: String],
        jsonBody: String?,
        completionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void,
        andUsingRequestPreHandler requestPreHandler: ((URLRequest) -> URLRequest)? = nil
        ) -> URLSessionDataTask? {

        guard let url = getURL(fromPath: path, andParameters: parameters) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let headers = requiredAPIHeaders {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        if let requestPreHandler = requestPreHandler {
            request = requestPreHandler(request)
        }

        switch method {
        case .post:
            if let jsonBody = jsonBody {
                request.httpBody = jsonBody.data(using: .utf8)
            }
        default:
            break
        }

        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            let error = self.checkForErrors(inData: data, response: response, andError: error)
            guard error == nil else {
                handler(nil, error)
                return
            }

            // Pre-handle the data, if necessary.
            let data = self.preHandleData?(data!) ?? data!

            guard let json = self.deserializeJson(from: data) else {
                handler(nil, RequestError.malformedJson)
                return
            }

            handler(json, nil)
        }

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
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

    /// Mounts a base URL using the passed parameters.
    /// - Parameters:
    ///     - scheme: the networking protocol to be used.
    ///     - host: the host part of the url.
    ///     - path: the base path to be used.
    func mountBaseURL(usingScheme scheme: String, host: String, andPath path: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path

        return components.url
    }
}

extension String {

    /// Returns a string in which the key is substituted with the given value, if found.
    /// - Parameters:
    ///     - key: the key to be found and replaced.
    ///     - value: the value to be used when replacing the key.
    /// - Returns: the replaced string.
    func byReplacingKey(_ key: String, withValue value: String) -> String {
        return replacingOccurrences(of: "{\(key)}", with: value)
    }
}
