//
//  JwtBodyContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Declares error types and codes
///
/// - base64UrlStrIsInvalid: If given base64 string is invalid
@objc(VSSJwtBodyContentError) public enum JwtBodyContentError: Int, Error {
    case base64UrlStrIsInvalid = 1
}

/// Class representing JWT Body content
@objc(VSSJwtBodyContent) public class JwtBodyContent: NSObject {
    /// Issuer containing application id
    /// - Note: Can be taken [here](https://dashboard.virgilsecurity.com)
    @objc public var appId: String { return self.container.appId }
    /// Subject as identity
    @objc public var identity: String { return self.container.identity }
    /// Timestamp in seconds with expiration date
    @objc public var expiresAt: Date { return self.container.expiresAt }
    /// Timestamp in seconds with issued date
    @objc public var issuedAt: Date { return self.container.issuedAt }
    /// Dictionary with additional data
    @objc public var additionalData: [String: String]? { return self.container.additionalData }
    /// String representation
    @objc public let stringRepresentation: String

    private let container: Container

    private struct Container: Codable {
        let appId: String
        let identity: String
        let expiresAt: Date
        let issuedAt: Date
        let additionalData: [String: String]?

        private enum CodingKeys: String, CodingKey {
            case appId = "iss"
            case identity = "sub"
            case issuedAt = "iat"
            case expiresAt = "exp"
            case additionalData = "ada"
        }

        init(appId: String, identity: String, expiresAt: Date,
             issuedAt: Date, additionalData: [String: String]?) {
            self.appId = appId
            self.identity = identity
            self.expiresAt = expiresAt
            self.issuedAt = issuedAt
            self.additionalData = additionalData
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: Container.CodingKeys.self)

            let issuer = try values.decode(String.self, forKey: .appId)
            let subject = try values.decode(String.self, forKey: .identity)

            self.appId = issuer.replacingOccurrences(of: "virgil-", with: "")
            self.identity = subject.replacingOccurrences(of: "identity-", with: "")
            self.additionalData = try? values.decode(Dictionary.self, forKey: .additionalData)
            self.issuedAt = try values.decode(Date.self, forKey: .issuedAt)
            self.expiresAt = try values.decode(Date.self, forKey: .expiresAt)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode("virgil-" + self.appId, forKey: .appId)
            try container.encode("identity-" + self.identity, forKey: .identity)
            try container.encode(self.issuedAt, forKey: .issuedAt)
            try container.encode(self.expiresAt, forKey: .expiresAt)
            if let additionalData = self.additionalData {
                try container.encode(additionalData, forKey: .additionalData)
            }
        }
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - appId: Issuer containing application id. Can be taken [here](https://dashboard.virgilsecurity.com)
    ///   - identity: identity (must be equal to RawSignedModel identity when publishing card)
    ///   - expiresAt: expiration date
    ///   - issuedAt: issued date
    ///   - additionalData: dictionary with additional data
    /// - Throws: Rethrows from JSONEncoder
    @objc public init(appId: String, identity: String, expiresAt: Date,
                      issuedAt: Date, additionalData: [String: String]? = nil) throws {
        let container = Container(appId: appId, identity: identity,
                                  expiresAt: expiresAt,
                                  issuedAt: issuedAt,
                                  additionalData: additionalData)

        self.container = container
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(JsonHelper.timestampDateEncodingStrategy)

        self.stringRepresentation = try encoder.encode(container).base64UrlEncodedString()

        super.init()
    }

    /// Imports JwtBodyContent from base64Url encoded string
    ///
    /// - Parameter base64UrlEncoded: base64Url encoded string with JwtBodyContent
    /// - Throws: JwtBodyContentError.base64UrlStrIsInvalid If given base64 string is invalid
    ///           Rethrows from JSONDencoder
    @objc public init(base64UrlEncoded: String) throws {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            throw JwtBodyContentError.base64UrlStrIsInvalid
        }

        self.stringRepresentation = base64UrlEncoded
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(JsonHelper.timestampDateDecodingStrategy)
        self.container = try decoder.decode(Container.self, from: data)

        super.init()
    }
}
