//
//  Request.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/19/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

open class Request {
    public let url: URL
    public let method: Method
    public let headers: [String: String]?
    public let body: Data?

    public static let defaultTimeout: TimeInterval = 45

    public enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }

    public init(url: URL, method: Method, headers: [String: String]? = nil, body: Data? = nil) throws {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    public init(urlRequest: URLRequest) throws {
        guard let url = urlRequest.url,
            let methodStr = urlRequest.httpMethod,
            let method = Method(rawValue: methodStr) else {
                throw NSError()
        }

        self.url = url
        self.method = method
        self.headers = urlRequest.allHTTPHeaderFields
        self.body = urlRequest.httpBody
    }

    public func getNativeRequest() -> URLRequest {
        var request = URLRequest(url: self.url)

        request.timeoutInterval = Request.defaultTimeout
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body

        return request
    }
}
