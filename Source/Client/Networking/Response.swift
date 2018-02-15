//
//  Response.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/19/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// /// Represents Http response
open class Response: NSObject {
    /// HTTP status code
    public let statusCode: Int
    /// HTTP response
    public let response: HTTPURLResponse
    // Response body
    public let body: Data?

    /// Initializer
    ///
    /// - Parameters:
    ///   - statusCode: HTTP status code
    ///   - response: HTTP response
    ///   - body: HTTP response body
    public init(statusCode: Int, response: HTTPURLResponse, body: Data?) {
        self.statusCode = statusCode
        self.response = response
        self.body = body
    }
}
