//
//  JwtHeaderContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtHeaderContent) public class JwtHeaderContent: NSObject, Codable {
    @objc public let algorithm: String
    @objc public let type: String
    @objc public let contentType: String
    @objc public let keyIdentifier: String
    
    private enum CodingKeys: String, CodingKey {
        case algorithm     = "alg"
        case type          = "typ"
        case contentType   = "cty"
        case keyIdentifier = "kid"
    }
    
    @objc public init(algorithm: String = "VEDS512", type: String = "JWT", contentType: String = "virgil-jwt;v1", keyIdentifier: String) {
        self.algorithm     = algorithm
        self.type          = type
        self.contentType   = contentType
        self.keyIdentifier = keyIdentifier
        
        super.init()
    }
    
    @objc public convenience init?(string: String) {
        guard let data = Data(base64UrlEncoded: string),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        
        self.init(dict: json)
    }
    
    @objc public func exportAsString() throws -> String {
        return try self.asString()
    }
}
