//
//  CardManager+Export.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

// Import export cards
public extension CardManager {
    @objc func importCard(fromBase64EncodedString base64EncodedString: String) throws -> Card {
        let rawCard = try RawSignedModel.import(fromBase64Encoded: base64EncodedString)
        let card = try self.parseCard(from: rawCard)

        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        
        return card
    }

    @objc func importCard(fromJson json: Any) throws -> Card {
        let rawCard = try RawSignedModel.import(fromJson: json)
        let card = try self.parseCard(from: rawCard)

        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }

        return card
    }

    @objc func importCard(fromRawCard rawCard: RawSignedModel) throws -> Card {
        let card = try self.parseCard(from: rawCard)
        
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }

        return card
    }

    @objc func exportCardAsBase64EncodedString(card: Card) throws -> String {
        return try card.getRawCard(cardCrypto: self.cardCrypto).exportAsBase64EncodedString()
    }

    @objc func exportCardAsJson(card: Card) throws -> Any {
        return try card.getRawCard(cardCrypto: self.cardCrypto).exportAsJson()
    }

    @objc func exportCardAsRawCard(card: Card) throws -> RawSignedModel {
        return try card.getRawCard(cardCrypto: self.cardCrypto)
    }
}
