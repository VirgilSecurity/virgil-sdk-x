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
    @objc func importCard(string: String) throws -> Card {
        guard let rawCard = RawSignedModel.importFrom(base64Encoded: string),
            let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: rawCard) else {
                throw CardManagerError.cardIsCorrupted
        }
        
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        return card
    }
    
    @objc func importCard(json: Any) throws -> Card {
        guard let rawCard = RawSignedModel.importFrom(json: json),
            let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: rawCard) else {
                throw CardManagerError.cardIsCorrupted
        }
        
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        
        return card
    }
    
    @objc func importCard(from rawCard: RawSignedModel) throws -> Card {
        guard let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: rawCard) else {
            throw CardManagerError.cardIsCorrupted
        }
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        
        return card
    }
    
    @objc func exportAsBase64String(card: Card) throws -> String {
        return try card.getRawCard(cardCrypto: self.cardCrypto).base64EncodedString()
    }
    
    @objc func exportAsJson(card: Card) throws -> Any {
        return try card.getRawCard(cardCrypto: self.cardCrypto).exportAsJson()
    }
    
    @objc func exportAsRawCard(card: Card) throws -> RawSignedModel {
        return try card.getRawCard(cardCrypto: self.cardCrypto)
    }
}
