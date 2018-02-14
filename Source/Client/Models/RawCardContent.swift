//
//  RawCardContent.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents content of Virgil Card
@objc(VSSRawCardContent) public class RawCardContent: NSObject, Codable {
    /// Card identity
    @objc public let identity: String
    /// Base64 encoded string with PublicKey data
    @objc public let publicKey: String
    /// Identifier of outdated previous Virgil Card with same identity
    @objc public let previousCardId: String?
    /// Version of Virgil Card
    @objc public let version: String
    /// Timestamp in seconds with creation date
    @objc public let createdAt: Int

    /// Defines coding keys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case previousCardId = "previous_card_id"
        case createdAt = "created_at"
        case identity = "identity"
        case version = "version"
    }

    /// Initializes a new `RawCardContent` with the provided content
    ///
    /// - Parameters:
    ///   - identity: card identity
    ///   - publicKey: base64 encoded string with PublicKey data of Virgil Card
    ///   - previousCardId: identifier of previous Virgil Card with same identity
    ///   - version: Virgil Card version
    ///   - createdAt: date of creation
    @objc public init(identity: String, publicKey: String, previousCardId: String? = nil,
                      version: String = "5.0", createdAt: Date) {
        self.identity = identity
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.version = version
        self.createdAt = Int(createdAt.timeIntervalSince1970)

        super.init()
    }

    /// Initializes `RawCardContent` from data snapshot
    ///
    /// - Parameter snapshot: snapshot of `RawCardContent`
    @objc public convenience init?(snapshot: Data) {
        guard let content = try? JSONDecoder().decode(RawCardContent.self, from: snapshot) else {
            return nil
        }

        self.init(identity: content.identity, publicKey: content.publicKey,
                  previousCardId: content.previousCardId, version: content.version,
                  createdAt: Date(timeIntervalSince1970: TimeInterval(content.createdAt)))
    }

    /// Takes snapshot of `RawCardContent`
    ///
    /// - Returns: data snapshot of `RawCardContent`
    @objc public func snapshot() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
