//
//  RawServiceError.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Model for representing service errors
@objc(VSSRawServiceError) public final class RawServiceError: NSObject, Decodable {
    /// Code of error
    @objc public let code: Int
    /// Description of error
    @objc public let message: String

    /// Initializer
    ///
    /// - Parameters:
    ///   - code: Error code
    ///   - message: Error description
    internal init(code: Int, message: String) {
        self.code = code
        self.message = message

        super.init()
    }
}
