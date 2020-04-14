//
// Copyright (C) 2015-2020 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

/// Protocol for CardClient
///
/// See: CardClient for default implementation
@objc(VSSCardClientProtocol) public protocol CardClientProtocol: class {
    /// Returns `GetCardResponse` with `RawSignedModel` of card from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameter cardId: String with unique Virgil Card identifier
    /// - Returns: `GetCardResponse` if card found
    /// - Throws: Depends on implementation
    @objc func getCard(withId cardId: String) throws -> GetCardResponse

    /// Creates Virgil Card instance on the Virgil Cards Service
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should contain appropriate signatures
    ///
    /// - Parameter model: Signed `RawSignedModel`
    /// - Returns: `RawSignedModel` of created card
    /// - Throws: Depends on implementation
    @objc func publishCard(model: RawSignedModel) throws -> RawSignedModel

    /// Performs search of Virgil Cards using given identities on the Virgil Cards Service
    ///
    /// - Parameter identities: Identities of cards to search
    /// - Returns: Array with `RawSignedModel`s of matched Virgil Cards
    /// - Throws: Depends on implementation
    @objc func searchCards(identities: [String]) throws -> [RawSignedModel]

    /// Returns list of cards that were replaced with newer ones
    ///
    /// - Parameter cardIds: card ids to check
    /// - Returns: List of old card ids
    /// - Throws: Depends on implementation
    @objc func getOutdated(cardIds: [String]) throws -> [String]

    /// Revokes card. Revoked card gets isOutdated flag to be set to true.
    /// Also, such cards could be obtained using get query, but will be absent in search query result.
    ///
    /// - Parameter cardId: identifier of card to revoke
    /// - Throws: Depends on implementation
    @objc func revokeCard(withId cardId: String) throws
}
