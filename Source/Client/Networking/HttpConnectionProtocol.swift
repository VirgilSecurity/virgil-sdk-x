//
//  HttpConnectionProtocol.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Protocol for HTTP connection
///
/// See: HttpConnection for default implementation
public protocol HttpConnectionProtocol: class {
    /// Sends Request and returns Response
    ///
    /// - Parameter request: Request to send
    /// - Returns: Obrained response
    /// - Throws: Depends on implementation
    func send(_ request: Request) throws -> Response
}
