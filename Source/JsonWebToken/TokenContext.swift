//
//  TokenContext.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/25/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class used to provide additional info for AccessTokenProvider and explains why token is needed
@objc(VSSTokenContext) public class TokenContext: NSObject {
    /// Identity to use in token
    @objc public let identity: String?
    /// Operation for which token is needed
    /// CardManager uses following operations:
    /// - "get"
    /// - "search"
    /// - "publish"
    @objc public let operation: String
    /// AccessTokenProvider should reset cached token, if such exist
    @objc public let forceReload: Bool

    /// Initializer
    ///
    /// - Parameters:
    ///   - identity: Identity to use in token
    ///   - operation: Operation for which token is needed
    ///   - forceReload: AccessTokenProvider should reset cached token, if such exist
    @objc public init(identity: String? = nil, operation: String, forceReload: Bool = false) {
        self.identity = identity
        self.operation = operation
        self.forceReload = forceReload
    }
}
