//
//  Card.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class representing Virgil Card
@objc(VSSCard) public class Card: NSObject {
    /// Identifier of Virgil Card
    /// - Note: Is unique
    @objc public let identifier: String
    /// Virgil Card identity
    @objc public let identity: String
    /// PublicKey of Virgil Card
    @objc public let publicKey: PublicKey
    /// Identifier of outdated previous Virgil Card with same identity
    @objc public let previousCardId: String?
    /// Previous Virgil Card instance
    @objc public var previousCard: Card?
    /// True if Virgil Card is outdated, false otherwise
    @objc public var isOutdated: Bool
    /// Version of Virgil Card
    @objc public let version: String
    /// Creation date of Virgil Card
    @objc public let createdAt: Date
    /// Array with CardSignatures of Virgil Card
    @objc public let signatures: [CardSignature]
    /// Snapshot of corresponding `RawCardContent`
    @objc public let contentSnapshot: Data

    internal init(identifier: String, identity: String, publicKey: PublicKey,
                  isOutdated: Bool = false, version: String, createdAt: Date,
                  signatures: [CardSignature], previousCardId: String? = nil,
                  previousCard: Card? = nil, contentSnapshot: Data) {
        self.identifier = identifier
        self.identity = identity
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.previousCard = previousCard
        self.isOutdated = isOutdated
        self.version = version
        self.createdAt = createdAt
        self.signatures = signatures
        self.contentSnapshot = contentSnapshot

        super.init()
    }

    /// Imports Virgil Card from RawSignedModel
    ///
    /// - Parameters:
    ///   - cardCrypto: `CardCrypto` instance
    ///   - rawSignedModel: RawSignedModel to import
    /// - Returns: imported Card if succeeded
    @objc public class func parse(cardCrypto: CardCrypto, rawSignedModel: RawSignedModel) -> Card? {
        let contentSnapshot = rawSignedModel.contentSnapshot
        guard let rawCardContent = try? JSONDecoder().decode(RawCardContent.self, from: contentSnapshot) else {
            return nil
        }

        guard let publicKeyData = Data(base64Encoded: rawCardContent.publicKey),
              let publicKey = try? cardCrypto.importPublicKey(from: publicKeyData),
              let fingerprint = try? cardCrypto.generateSHA512(for: rawSignedModel.contentSnapshot) else {
                return nil
        }

        let cardId = fingerprint.subdata(in: 0..<32).hexEncodedString()

        var cardSignatures: [CardSignature] = []
        for rawSignature in rawSignedModel.signatures {
            let extraFields: [String: String]?

            if let rawSnapshot = rawSignature.snapshot,
                let json = try? JSONSerialization.jsonObject(with: rawSnapshot, options: []),
                   let result = json as? [String: String] {
                    extraFields = result
                }
            else {
                extraFields = nil
            }

            let cardSignature = CardSignature(signer: rawSignature.signer, signature: rawSignature.signature,
                                              snapshot: rawSignature.snapshot, extraFields: extraFields)

            cardSignatures.append(cardSignature)
        }
        let createdAt = Date(timeIntervalSince1970: TimeInterval(rawCardContent.createdAt))

        return Card(identifier: cardId, identity: rawCardContent.identity, publicKey: publicKey,
                    version: rawCardContent.version, createdAt: createdAt, signatures: cardSignatures,
                    previousCardId: rawCardContent.previousCardId, contentSnapshot: rawSignedModel.contentSnapshot)
    }

    /// Builds RawSignedModel representing Card
    ///
    /// - Returns: RawSignedModel representing Card
    /// - Throws: corresponding error
    @objc public func getRawCard() throws -> RawSignedModel {
        let rawCard = RawSignedModel(contentSnapshot: self.contentSnapshot)

        for cardSignature in self.signatures {
            let signature = RawSignature(signer: cardSignature.signer,
                                         signature: cardSignature.signature,
                                         snapshot: cardSignature.snapshot)

            try rawCard.addSignature(signature)
        }

        return rawCard
    }
}
