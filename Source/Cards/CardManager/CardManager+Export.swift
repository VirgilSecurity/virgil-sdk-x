//
//  CardManager+Export.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

// MARK: - Import export cards
extension CardManager {
    /// Imports and verifies Card from base64 encoded string
    ///
    /// - Parameter base64EncodedString: base64 encoded string with Card
    /// - Returns: imported and verified Card
    /// - Throws: CardManagerError.cardIsNotVerified, if Card verificaction has failed
    ///           Rethrows from RawSignedModel, JSONDecoder, CardCrypto
    @objc open func importCard(fromBase64Encoded base64EncodedString: String) throws -> Card {
        let rawCard = try RawSignedModel.import(fromBase64Encoded: base64EncodedString)
        let card = try self.parseCard(from: rawCard)

        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }

        return card
    }

    /// Imports and verifies Card from json Dictionary
    ///
    /// - Parameter json: json Dictionary
    /// - Returns: imported and verified Card
    /// - Throws: CardManagerError.cardIsNotVerified, if Card verificaction has failed
    ///           Rethrows from RawSignedModel, JSONDecoder, CardCrypto, JSONSerialization
    @objc open func importCard(fromJson json: Any) throws -> Card {
        let rawCard = try RawSignedModel.import(fromJson: json)
        let card = try self.parseCard(from: rawCard)

        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }

        return card
    }

    /// Imports and verifies Card from RawSignedModel
    ///
    /// - Parameter rawCard: RawSignedModel
    /// - Returns: imported and verified Card
    /// - Throws: CardManagerError.cardIsNotVerified, if Card verificaction has failed
    ///           Rethrows from RawSignedModel, JSONDecoder, CardCrypto, JSONSerialization
    @objc open func importCard(fromRawCard rawCard: RawSignedModel) throws -> Card {
        let card = try self.parseCard(from: rawCard)

        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }

        return card
    }

    /// Exports Card as base64 encoded string
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: base64 encoded string with Card
    /// - Throws: CardManagerError.cardIsNotVerified, if Card verificaction has failed
    ///           Rethrows from RawSignedModel, JSOEncoder, CardCrypto
    @objc open func exportCardAsBase64EncodedString(_ card: Card) throws -> String {
        return try card.getRawCard().exportAsBase64EncodedString()
    }

    /// Exports Card as json Dictionary
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: json Dictionary with Card
    /// - Throws: CardManagerError.cardIsNotVerified, if Card verificaction has failed
    ///           Rethrows from RawSignedModel, JSOEncoder, CardCrypto, JSONSerialization
    @objc open func exportCardAsJson(_ card: Card) throws -> Any {
        return try card.getRawCard().exportAsJson()
    }
    /// Exports Card as RawSignedModel
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: RawSignedModel representing Card
    /// - Throws: CardManagerError.cardIsNotVerified, if Card verificaction has failed
    ///           Rethrows from RawSignedModel, JSOEncoder, CardCrypto
    @objc open func exportCardAsRawCard(_ card: Card) throws -> RawSignedModel {
        return try card.getRawCard()
    }
}
