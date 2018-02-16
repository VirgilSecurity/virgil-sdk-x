//
//  JwtHeaderContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing JWT Header content
@objc(VSSJwtHeaderContent) public class JwtHeaderContent: NSObject {
    @objc(VSSJwtHeaderContentError) public enum JwtHeaderContentError: Int, Error {
        case base64UrlStrIsInvalid = 1
    }
    
    private let container: Container
    
    /// Represents used signature algorithm
    @objc public var algorithm: String { return self.container.algorithm }
    /// Represents token type
    @objc public var type: String { return self.container.type }
    /// Represents content type for this JWT
    @objc public var contentType: String { return self.container.contentType }
    /// Represents identifier of public key which should be used to verify signature
    /// - Note: Can be taken from [here](https://dashboard.virgilsecurity.com/api-keys)
    @objc public var keyIdentifier: String { return self.container.keyIdentifier }
    @objc public let stringRepresentation: String

    private struct Container: Codable {
        let algorithm: String
        let type: String
        let contentType: String
        let keyIdentifier: String
        
        private enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case type = "typ"
            case contentType = "cty"
            case keyIdentifier = "kid"
        }
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - algorithm: used signature algorithm
    ///   - type: token type
    ///   - contentType: content type for this JWT
    ///   - keyIdentifier: identifier of public key which should be used to verify signature
    @objc public init(algorithm: String = "VEDS512", type: String = "JWT",
                      contentType: String = "virgil-jwt;v=1", keyIdentifier: String) throws {
        let container = Container(algorithm: algorithm, type: type,
                                  contentType: contentType, keyIdentifier: keyIdentifier)
        self.container = container
        self.stringRepresentation = try JSONEncoder().encode(container).base64UrlEncodedString()

        super.init()
    }

    /// Imports JwtHeaderContent from base64Url encoded string
    ///
    /// - Parameter base64UrlEncoded: base64Url encoded string with JwtHeaderContent
    /// - Returns: decoded JwtHeaderContent if succeeded, nil otherwise
    @objc public init(base64UrlEncoded: String) throws  {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            throw JwtHeaderContentError.base64UrlStrIsInvalid
        }

        self.container = try JSONDecoder().decode(Container.self, from: data)
        self.stringRepresentation = base64UrlEncoded
    }
}
