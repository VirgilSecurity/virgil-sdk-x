//
//  JwtBodyContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtBodyContent) public class JwtBodyContent: NSObject, Codable {
    let appId: String
    let identity: String
    let additionalData: [String : String]
    let expiresAt: Date
    let issuedAt: Date

    private enum CodingKeys: String, CodingKey {
        case appId          = "iss"
        case identity       = "sub"
        case additionalData = "ada"
        case issuedAt       = "iat"
        case expiresAt      = "exp"
    }
    
    @objc public init(appId: String, identity: String, expiresAt: Date, issuedAt: Date, additionalData: [String : String]? = nil) {
        self.appId          = appId
        self.identity       = identity
        self.expiresAt      = expiresAt
        self.issuedAt       = issuedAt
        self.additionalData = additionalData ?? [:]
        
        super.init()
    }
    
    @objc public convenience init?(jwtBody: String) {
        guard let data = Data(base64UrlEncoded: jwtBody),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        
        self.init(dict: json)
    }
    
    @objc public func export() throws -> String {
        return try self.asString()
    }
}

