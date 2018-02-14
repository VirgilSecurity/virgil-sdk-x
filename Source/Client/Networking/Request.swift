//
//  Request.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/19/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents Http request
open class Request {
    /// Declares error types and codes
    ///
    /// - urlRequestIsIncompleteOrInvalid: Provided URLRequest is incomplete or invalid
    @objc(VSSRequestError) public enum RequestError: Int, Error {
        case urlRequestIsIncompleteOrInvalid = 1
    }

    /// Url of request
    public let url: URL
    /// Http method
    public let method: Method
    /// Request headers
    public let headers: [String: String]?
    /// Request body
    public let body: Data?

    /// Default request timeout
    public static let defaultTimeout: TimeInterval = 45

    /// Http methods
    ///
    /// - get
    /// - post
    /// - put
    /// - delete
    public enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - url: Request url
    ///   - method: Request method
    ///   - headers: Request headers
    ///   - body: Request body
    public init(url: URL, method: Method, headers: [String: String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    /// Initializer from URLRequest
    ///
    /// - Parameter urlRequest: URLRequest
    /// - Throws: RequestError.urlRequestIsIncompleteOrInvalid if URLRequest is incomplete or invalid
    public init(urlRequest: URLRequest) throws {
        guard let url = urlRequest.url,
            let methodStr = urlRequest.httpMethod,
            let method = Method(rawValue: methodStr) else {
                throw RequestError.urlRequestIsIncompleteOrInvalid
        }

        self.url = url
        self.method = method
        self.headers = urlRequest.allHTTPHeaderFields
        self.body = urlRequest.httpBody
    }

    /// Returns URLRequest created from this Request
    ///
    /// - Returns: URLRequest
    public func getNativeRequest() -> URLRequest {
        var request = URLRequest(url: self.url)

        request.timeoutInterval = Request.defaultTimeout
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body

        return request
    }
}
