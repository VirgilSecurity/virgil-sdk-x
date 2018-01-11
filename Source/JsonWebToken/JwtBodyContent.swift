//
//  JwtBodyContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtBodyContent) public class JwtBodyContent: NSObject, Serializable {
    let appId: String
    let identity: String
    let additionalData: [String : Any]
    let expiresAt: Date
    let issuedAt: Date

    private enum Keys: String {
        case appId          = "iss"
        case identity       = "sub"
        case additionalData = "ada"
        case issuedAt       = "iat"
        case expiresAt      = "exp"
    }
    
    @objc public init(appId: String, identity: String, expiresAt: Date, issuedAt: Date, additionalData: [String : Any] = [:]) {
        self.appId          = appId
        self.identity       = identity
        self.expiresAt      = expiresAt
        self.issuedAt       = issuedAt
        self.additionalData = additionalData
    }
    
    public func serialize() -> Any {
        return [
            Keys.appId.rawValue:          "virgil-" + self.appId,
            Keys.identity.rawValue:       "identity-" + self.identity,
            Keys.additionalData.rawValue: self.additionalData,
            Keys.issuedAt.rawValue:       self.expiresAt,
            Keys.expiresAt.rawValue:      self.issuedAt
        ]
    }
}

