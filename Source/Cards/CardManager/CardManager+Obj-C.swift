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
import VirgilCrypto

//Objective-C compatible Queries
extension CardManager {
    /// Asynchronously returns `Card` with given identifier
    /// from the Virgil Cards Service with given ID, if exists
    ///
    /// - Note: See swift version for additional info
    ///
    /// - Parameters:
    ///   - cardId: string with unique Virgil Card identifier
    ///   - completion: completion handler, called with found and verified Card or corresponding error
    @objc open func getCard(withId cardId: String, completion: @escaping (Card?, Error?) -> Void) {
        self.getCard(withId: cardId).start(completion: completion)
    }

    /// Asynchronously creates Virgil Card instance on the Virgil Cards Service and associates it with unique identifier
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should be at least selfSigned
    ///
    /// - Note: See swift version for additional info
    ///
    /// - Parameters:
    ///   - rawCard: self signed `RawSignedModel`
    ///   - completion: completion handler, called with published and verified Card or corresponding error
    @objc open func publishCard(rawCard: RawSignedModel, completion: @escaping (Card?, Error?) -> Void) {
        self.publishCard(rawCard: rawCard).start(completion: completion)
    }

    /// Asynchronously generates self signed RawSignedModel and creates Virgil Card
    /// instance on the Virgil Cards Service and associates it with unique identifier
    ///
    /// - Note: See swift version for additional info
    ///
    /// - Parameters:
    ///   - privateKey: Private Key to self sign RawSignedModel with
    ///   - publicKey: VirgilPublicKey for generating RawSignedModel
    ///   - identity: identity for generating RawSignedModel. Will be taken from token if omitted
    ///   - previousCardId: identifier of Virgil Card to replace
    ///   - extraFields: Dictionary with extra data to sign with model
    ///   - completion: completion handler, called with published and verified Card or corresponding error
    @objc open func publishCard(privateKey: VirgilPrivateKey, publicKey: VirgilPublicKey, identity: String,
                                previousCardId: String? = nil, extraFields: [String: String]? = nil,
                                completion: @escaping (Card?, Error?) -> Void) {
        self.publishCard(privateKey: privateKey,
                         publicKey: publicKey,
                         identity: identity,
                         previousCardId: previousCardId,
                         extraFields: extraFields)
            .start(completion: completion)
    }

    /// Asynchronously performs search of Virgil Cards on the Virgil Cards Service using identities
    ///
    /// - Note: See swift version for additional info
    ///
    /// - Parameters:
    ///   - identities: identities of cards to search
    ///   - completion: completion handler, called with found and verified Cards or corresponding error
    @objc open func searchCards(identities: [String], completion: @escaping ([Card]?, Error?) -> Void) {
        self.searchCards(identities: identities).start(completion: completion)
    }

    /// Returns list of cards that were replaced with newer ones
    ///
    /// - Parameters:
    ///   - cardIds: card ids to check
    ///   - completion: completion handler, called with list of old card ids or corresponding error
    @objc open func getOutdated(cardIds: [String], completion: @escaping ([String]?, Error?) -> Void) {
        self.getOutdated(cardIds: cardIds).start(completion: completion)
    }

    /// Makes CallbackOperation<Void> for performing revokation of Virgil Card
    ///
    /// Revoked card gets isOutdated flag to be set to true.
    /// Also, such cards could be obtained using get query, but will be absent in search query result.
    ///
    /// - Parameters:
    ///   - cardId: identifier of card to revoke
    ///   - completion: completion handler, called with corresponding error if any occured
    @objc open func revokeCard(withId cardId: String,
                               completion: @escaping (Error?) -> Void) {
        self.revokeCard(withId: cardId).start { _, error in
            completion(error)
        }
    }
}
