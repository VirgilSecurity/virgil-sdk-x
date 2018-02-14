//
//  JwtHeaderContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing JWT Header content
@objc(VSSJwtHeaderContent) public class JwtHeaderContent: NSObject, Codable {
    /// Represents used signature algorithm
    @objc public let algorithm: String
    /// Represents token type
    @objc public let type: String
    /// Represents content type for this JWT
    @objc public let contentType: String
    /// Represents identifier of public key which should be used to verify signature
    /// - Note: Can be taken from [here](https://dashboard.virgilsecurity.com/api-keys)
    @objc public let keyIdentifier: String

    /// Defines coding keys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case algorithm = "alg"
        case type = "typ"
        case contentType = "cty"
        case keyIdentifier = "kid"
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - algorithm: used signature algorithm
    ///   - type: token type
    ///   - contentType: content type for this JWT
    ///   - keyIdentifier: identifier of public key which should be used to verify signature
    @objc public init(algorithm: String = "VEDS512", type: String = "JWT",
                      contentType: String = "virgil-jwt;v=1", keyIdentifier: String) {
        self.algorithm = algorithm
        self.type = type
        self.contentType = contentType
        self.keyIdentifier = keyIdentifier

        super.init()
    }

    /// Imports JwtHeaderContent from base64Url encoded string
    ///
    /// - Parameter base64UrlEncoded: base64Url encoded string with JwtHeaderContent
    /// - Returns: decoded JwtHeaderContent if succeeded, nil otherwise
    @objc public static func importFrom(base64UrlEncoded: String) -> JwtHeaderContent? {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            return nil
        }

        return try? JSONDecoder().decode(JwtHeaderContent.self, from: data)
    }

    /// Exports JwtHeaderContent as base64Url encoded string
    ///
    /// - Returns: base64Url encoded string with JwtHeaderContent
    /// - Throws: corresponding error if encoding failed
    @objc public func base64UrlEncodedString() throws -> String {
        return try JSONEncoder().encode(self).base64UrlEncodedString()
    }
}
