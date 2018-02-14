//
//  TokenContext.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/25/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class used to provide additional info for AccessTokenProvider about for what token will be used
@objc(VSSTokenContext) public class TokenContext: NSObject {
    /// Identity to use in token
    @objc public let identity: String?
    /// Explanation of the purpose of token usage
    @objc public let operation: String
    /// Tells providers not to use cashed tokens if true
    @objc public let forceReload: Bool

    /// Initializer
    ///
    /// - Parameters:
    ///   - identity: identity to use in token
    ///   - operation: explanation of the purpose of token usage
    ///   - forceReload: tells providers not to use cashed tokens if true
    @objc public init(identity: String? = nil, operation: String, forceReload: Bool = false) {
        self.identity = identity
        self.operation = operation
        self.forceReload = forceReload
    }
}
