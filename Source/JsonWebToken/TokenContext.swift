//
//  TokenContext.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/25/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSTokenContext) public class TokenContext: NSObject {
    @objc public let identity: String?
    @objc public let operation: String
    @objc public let forceReload: Bool

    @objc public init(identity: String? = nil, operation: String, forceReload: Bool = false) {
        self.identity = identity
        self.operation = operation
        self.forceReload = forceReload
    }
}
