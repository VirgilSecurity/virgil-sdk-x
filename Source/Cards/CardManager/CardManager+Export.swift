//
//  CardManager+Export.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Import export cards
public extension CardManager {
    /// Imports and verifies Card from base64 encoded string
    ///
    /// - Parameter string: base64 encoded string with Card
    /// - Returns: imported and verified Card
    /// - Throws: corresponding CardManagerError
    @objc func importCard(base64Encoded string: String) throws -> Card {
        guard let rawCard = RawSignedModel.importFrom(base64Encoded: string),
            let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: rawCard) else {
                throw CardManagerError.cardIsCorrupted
        }

        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        return card
    }

    /// Imports and verifies Card from json Dictionary
    ///
    /// - Parameter json: json Dictionary
    /// - Returns: imported and verified Card
    /// - Throws: corresponding CardManagerError
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

    /// Imports and verifies Card from RawSignedModel
    ///
    /// - Parameter rawCard: RawSignedModel
    /// - Returns: imported and verified Card
    /// - Throws: corresponding CardManagerError
    @objc func importCard(from rawCard: RawSignedModel) throws -> Card {
        guard let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: rawCard) else {
            throw CardManagerError.cardIsCorrupted
        }
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }

        return card
    }

    /// Exports Card as base64 encoded string
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: base64 encoded string with Card
    /// - Throws: corresponding Error
    @objc func exportAsBase64String(card: Card) throws -> String {
        return try card.getRawCard().base64EncodedString()
    }

    /// Exports Card as json Dictionary
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: json Dictionary with Card
    /// - Throws: corresponding Error
    @objc func exportAsJson(card: Card) throws -> Any {
        return try card.getRawCard().exportAsJson()
    }

    /// Exports Card as RawSignedModel
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: RawSignedModel representing Card
    /// - Throws: corresponding Error
    @objc func exportAsRawCard(card: Card) throws -> RawSignedModel {
        return try card.getRawCard()
    }
}
