//
//  JwtHeaderContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Declares error types and codes
///
/// - base64UrlStrIsInvalid: If given base64 string is invalid
@objc(VSSJwtHeaderContentError) public enum JwtHeaderContentError: Int, Error {
    case base64UrlStrIsInvalid = 1
}

/// Class representing JWT Header content
@objc(VSSJwtHeaderContent) public class JwtHeaderContent: NSObject {
    /// Represents used signature algorithm
    @objc public var algorithm: String { return self.container.algorithm }
    /// Represents token type
    @objc public var type: String { return self.container.type }
    /// Represents content type for this JWT
    @objc public var contentType: String { return self.container.contentType }
    /// Represents identifier of public key which should be used to verify signature
    /// - Note: Can be taken from [here](https://dashboard.virgilsecurity.com/api-keys)
    @objc public var keyIdentifier: String { return self.container.keyIdentifier }
    /// String representation
    @objc public let stringRepresentation: String

    private let container: Container

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
    /// - Throws: Rethrows from JSONEncoder
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
    /// - Throws: JwtHeaderContentError.base64UrlStrIsInvalid If given base64 string is invalid
    ///           Rethrows from JSONDecoder
    @objc public init(base64UrlEncoded: String) throws {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            throw JwtHeaderContentError.base64UrlStrIsInvalid
        }

        self.container = try JSONDecoder().decode(Container.self, from: data)
        self.stringRepresentation = base64UrlEncoded
    }
}
