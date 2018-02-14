//
//  HttpConnectionProtocol.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Protocol for HTTP connection
public protocol HttpConnectionProtocol: class {
    /// Sends Request and returns Response
    ///
    /// - Parameter request: Request to send
    /// - Returns: Obrained response
    /// - Throws: Any Error
    func send(_ request: Request) throws -> Response
}
