//
//  JwtBodyContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing JWT Body content
@objc(VSSJwtBodyContent) public class JwtBodyContent: NSObject, Codable {
    /// Issuer containing application id
    /// - Note: Can be taken [here](https://dashboard.virgilsecurity.com)
    @objc public let appId: String
    /// Subject as identity
    @objc public let identity: String
    /// Timestamp in seconds with expiration date
    @objc public let expiresAt: Int
    /// Timestamp in seconds with issued date
    @objc public let issuedAt: Int
    /// Dictionary with additional data
    @objc public let additionalData: [String: String]?

    /// Defines coding keys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case appId = "iss"
        case identity = "sub"
        case issuedAt = "iat"
        case expiresAt = "exp"
        case additionalData = "ada"
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - appId: Issuer containing application id. Can be taken [here](https://dashboard.virgilsecurity.com)
    ///   - identity: identity (must be equal to RawSignedModel identity when publishing card)
    ///   - expiresAt: expiration date
    ///   - issuedAt: issued date
    ///   - additionalData: dictionary with additional data
    @objc public init(appId: String, identity: String, expiresAt: Date,
                      issuedAt: Date, additionalData: [String: String]? = nil) {
        self.appId = appId
        self.identity = identity
        self.expiresAt = Int(expiresAt.timeIntervalSince1970)
        self.issuedAt = Int(issuedAt.timeIntervalSince1970)
        self.additionalData = additionalData

        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let issuer = try values.decode(String.self, forKey: .appId)
        let subject = try values.decode(String.self, forKey: .identity)

        self.appId = issuer.replacingOccurrences(of: "virgil-", with: "")
        self.identity = subject.replacingOccurrences(of: "identity-", with: "")
        self.additionalData = try? values.decode(Dictionary.self, forKey: .additionalData)
        self.issuedAt = try values.decode(Int.self, forKey: .issuedAt)
        self.expiresAt = try values.decode(Int.self, forKey: .expiresAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("virgil-" + self.appId, forKey: .appId)
        try container.encode("identity-" + self.identity, forKey: .identity)
        try container.encode(self.issuedAt, forKey: .issuedAt)
        try container.encode(self.expiresAt, forKey: .expiresAt)
        if let additionalData = self.additionalData {
            try container.encode(additionalData, forKey: .additionalData)
        }
    }

    /// Imports JwtBodyContent from base64Url encoded string
    ///
    /// - Parameter base64UrlEncoded: base64Url encoded string with JwtBodyContent
    /// - Returns: decoded JwtBodyContent if succeeded, nil otherwise
    @objc public static func importFrom(base64UrlEncoded: String) -> JwtBodyContent? {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            return nil
        }

        return try? JSONDecoder().decode(JwtBodyContent.self, from: data)
    }

    /// Exports JwtBodyContent as base64Url encoded string
    ///
    /// - Returns: base64Url encoded string with JwtBodyContent
    /// - Throws: corresponding error if encoding failed
    @objc public func base64UrlEncodedString() throws -> String {
        return try JSONEncoder().encode(self).base64UrlEncodedString()
    }
}
