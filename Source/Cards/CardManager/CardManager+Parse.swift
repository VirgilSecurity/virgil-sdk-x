//
//  CardManager+Parse.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/14/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

public extension CardManager {
    /// Imports Virgil Card from RawSignedModel
    ///
    /// - Parameters:
    ///   - cardCrypto: `CardCrypto` instance
    ///   - rawSignedModel: RawSignedModel to import
    /// - Returns: imported Card
    /// - Throws: corresponding error
    @objc static func parseCard(from rawSignedModel: RawSignedModel, cardCrypto: CardCrypto) throws -> Card {
        let contentSnapshot = rawSignedModel.contentSnapshot
        let rawCardContent = try JSONDecoder().decode(RawCardContent.self, from: contentSnapshot)
        
        guard let publicKeyData = Data(base64Encoded: rawCardContent.publicKey) else {
            throw CardManagerError.invalidPublicKeyBase64String
        }
        
        let publicKey = try cardCrypto.importPublicKey(from: publicKeyData)
        let fingerprint = try cardCrypto.generateSHA512(for: rawSignedModel.contentSnapshot)
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

    /// Imports Virgil Card from RawSignedModel using self CardCrypto instance
    ///
    /// - Parameters:
    ///   - rawSignedModel: RawSignedModel to import
    /// - Returns: imported Card
    /// - Throws: corresponding error
    @objc func parseCard(from rawSignedModel: RawSignedModel) throws -> Card {
        return try CardManager.parseCard(from: rawSignedModel, cardCrypto: self.cardCrypto)
    }
}
