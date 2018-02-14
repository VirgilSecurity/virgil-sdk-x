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
    @objc func importCard(fromBase64EncodedString base64EncodedString: String) throws -> Card {
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
    /// - Throws: corresponding CardManagerError
    @objc func importCard(fromJson json: Any) throws -> Card {
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
    /// - Throws: corresponding CardManagerError
    @objc func importCard(fromRawCard rawCard: RawSignedModel) throws -> Card {
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
    /// - Throws: corresponding Error
    @objc func exportCardAsBase64EncodedString(card: Card) throws -> String {
        return try card.getRawCard().exportAsBase64EncodedString()
    }

    /// Exports Card as json Dictionary
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: json Dictionary with Card
    /// - Throws: corresponding Error
    @objc func exportCardAsJson(card: Card) throws -> Any {
        return try card.getRawCard().exportAsJson()
    }

    /// Exports Card as RawSignedModel
    ///
    /// - Parameter card: Card to be exported
    /// - Returns: RawSignedModel representing Card
    /// - Throws: corresponding Error
    @objc func exportCardAsRawCard(card: Card) throws -> RawSignedModel {
        return try card.getRawCard()
    }
}
