//
//  RawCardContent.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents content of Virgil Card
@objc(VSSRawCardContent) public final class RawCardContent: NSObject, Codable {
    /// Card identity
    @objc public let identity: String
    /// PublicKey data
    @objc public let publicKey: Data
    /// Identifier of outdated previous Virgil Card with same identity.
    @objc public let previousCardId: String?
    /// Version of Virgil Card
    @objc public let version: String
    /// UTC timestamp of creation date
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
    ///   - identity: Card identity
    ///   - publicKey: PublicKey data
    ///   - previousCardId: Identifier of previous Virgil Card with same identity
    ///   - version: Virgil Card version
    ///   - createdAt: Date of creation
    @objc public init(identity: String, publicKey: Data, previousCardId: String? = nil,
                      version: String = "5.0", createdAt: Date) {
        self.identity = identity
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.version = version
        self.createdAt = Int(createdAt.timeIntervalSince1970)

        super.init()
    }

    /// Initializes `RawCardContent` from binary content snapshot
    ///
    /// - Parameter snapshot: Binary snapshot of `RawCardContent`
    /// - Throws: Rethrows from JSONDecoder
    @objc public convenience init(snapshot: Data) throws {
        let content = try JSONDecoder().decode(RawCardContent.self, from: snapshot)

        self.init(identity: content.identity, publicKey: content.publicKey,
                  previousCardId: content.previousCardId, version: content.version,
                  createdAt: Date(timeIntervalSince1970: TimeInterval(content.createdAt)))
    }

    /// Takes binary snapshot of `RawCardContent`
    ///
    /// - Returns: Binary snapshot of `RawCardContent`
    /// - Throws: Rethrows from JSONEncoder
    @objc public func snapshot() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
