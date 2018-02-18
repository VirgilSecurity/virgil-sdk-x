//
//  CardClientProtocol.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Protocol for CardClient
///
/// See: CardClient for default implementation
@objc(VSSCardClientProtocol) public protocol CardClientProtocol: class {
    /// Returns `GetCardResponse` with `RawSignedModel` of card from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameters:
    ///   - cardId: String with unique Virgil Card identifier
    ///   - token: String with `Access Token`
    /// - Returns: `GetCardResponse` if card found
    /// - Throws: Depends on implementation
    @objc func getCard(withId cardId: String, token: String) throws -> GetCardResponse

    /// Creates Virgil Card instance on the Virgil Cards Service
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should contain appropriate signatures
    ///
    /// - Parameters:
    ///   - model: Signed `RawSignedModel`
    ///   - token: String with `Access Token`
    /// - Returns: `RawSignedModel` of created card
    /// - Throws: Depends on implementation
    @objc func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel

    /// Performs search of Virgil Cards using given identity on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - identity: Identity of cards to search
    ///   - token: String with `Access Token`
    /// - Returns: Array with `RawSignedModel`s of matched Virgil Cards
    /// - Throws: Depends on implementation
    @objc func searchCards(identity: String, token: String) throws -> [RawSignedModel]
}
