//
//  Connection.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSHTTPResponse) public protocol HTTPResponse {
    var statusCode: Int { get }
    var response: HTTPURLResponse { get }
    var body: Data? { get }
}

@objc(VSSHTTPRequest) public protocol HTTPRequest {
    func getNativeRequest() -> URLRequest
}

@objc(VSSHTTPConnection) public protocol HTTPConnection: class {
    func send(_ request: HTTPRequest) throws -> HTTPResponse
}
