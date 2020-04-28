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

// MARK: - Extension for primary operations
extension CardManager {
    /// Makes CallbackOperation<Card> for getting verified Virgil Card
    /// from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameter cardId: identifier of Virgil Card to find
    /// - Returns: CallbackOperation<GetCardResponse> for getting `GetCardResponse` with verified Virgil Card
    open func getCard(withId cardId: String) -> GenericOperation<Card> {
        return CallbackOperation { _, completion in
            do {
                let responseModel = try self.cardClient.getCard(withId: cardId)

                let card = try self.parseCard(from: responseModel.rawCard)
                card.isOutdated = responseModel.isOutdated

                guard card.identifier == cardId else {
                    throw CardManagerError.gotWrongCard
                }

                guard self.cardVerifier.verifyCard(card) else {
                    throw CardManagerError.cardIsNotVerified
                }

                completion(card, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /// Generates self signed RawSignedModel
    ///
    /// - Parameters:
    ///   - privateKey: VirgilPrivateKey to self sign with
    ///   - publicKey: Public Key instance
    ///   - identity: Card's identity
    ///   - previousCardId: Identifier of Virgil Card with same identity this Card will replace
    ///   - extraFields: Dictionary with extra data to sign with model. Should be JSON-compatible
    /// - Returns: Self signed RawSignedModel
    /// - Throws: Rethrows from `VirgilCrypto`, `JSONEncoder`, `JSONSerialization`, `ModelSigner`
    @objc open func generateRawCard(privateKey: VirgilPrivateKey, publicKey: VirgilPublicKey,
                                    identity: String, previousCardId: String? = nil,
                                    extraFields: [String: String]? = nil) throws -> RawSignedModel {
        return try CardManager.generateRawCard(crypto: self.crypto,
                                               modelSigner: self.modelSigner,
                                               privateKey: privateKey,
                                               publicKey: publicKey,
                                               identity: identity,
                                               previousCardId: previousCardId,
                                               extraFields: extraFields)
    }

    /// Generates self signed RawSignedModel
    ///
    /// - Parameters:
    ///   - crypto: VirgilCrypto implementation
    ///   - modelSigner: ModelSigner implementation
    ///   - privateKey: VirgilPrivateKey to self sign with
    ///   - publicKey: Public Key instance
    ///   - identity: Card's identity
    ///   - previousCardId: Identifier of Virgil Card with same identity this Card will replace
    ///   - extraFields: Dictionary with extra data to sign with model. Should be JSON-compatible
    /// - Returns: Self signed RawSignedModel
    /// - Throws: Rethrows from `VirgilCrypto`, `JSONEncoder`, `JSONSerialization`, `ModelSigner`
    @objc open class func generateRawCard(crypto: VirgilCrypto, modelSigner: ModelSigner,
                                          privateKey: VirgilPrivateKey, publicKey: VirgilPublicKey,
                                          identity: String, previousCardId: String? = nil,
                                          extraFields: [String: String]? = nil) throws -> RawSignedModel {
        let exportedPubKey = try crypto.exportPublicKey(publicKey)

        let cardContent = RawCardContent(identity: identity,
                                         publicKey: exportedPubKey,
                                         previousCardId: previousCardId,
                                         createdAt: Date())

        let snapshot = try JSONEncoder().encode(cardContent)

        let rawCard = RawSignedModel(contentSnapshot: snapshot)

        var data: Data?
        if extraFields != nil {
            data = try JSONSerialization.data(withJSONObject: extraFields as Any, options: [])
        }
        else {
            data = nil
        }

        try modelSigner.selfSign(model: rawCard, privateKey: privateKey, additionalData: data)

        return rawCard
    }

    /// Makes CallbackOperation<Card> for creating Virgil Card instance
    /// on the Virgil Cards Service and associates it with unique identifier
    ///
    /// - Parameter rawCard: RawSignedModel of Card to create
    /// - Returns: CallbackOperation<Card> for creating Virgil Card instance
    open func publishCard(rawCard: RawSignedModel) -> GenericOperation<Card> {
        return CallbackOperation { _, completion in
            do {
                let signedRawCard = try CallbackOperation<RawSignedModel> { _, completion in
                    if let signCallback = self.signCallback {
                        signCallback(rawCard) { rawCard, error in
                            completion(rawCard, error)
                        }
                    }
                    else {
                        completion(rawCard, nil)
                    }
                }.startSync().get()

                let responseModel = try self.cardClient.publishCard(model: signedRawCard)

                guard responseModel.contentSnapshot == rawCard.contentSnapshot,
                    let selfSignature = rawCard.signatures
                        .first(where: { $0.signer == ModelSigner.selfSignerIdentifier }),
                    let responseSelfSignature = responseModel.signatures
                        .first(where: { $0.signer == ModelSigner.selfSignerIdentifier }),
                    selfSignature.snapshot == responseSelfSignature.snapshot else {
                        throw CardManagerError.gotWrongCard
                }

                let card = try self.parseCard(from: responseModel)

                guard self.cardVerifier.verifyCard(card) else {
                    throw CardManagerError.cardIsNotVerified
                }

                completion(card, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /// Makes CallbackOperation<Card> for generating self signed RawSignedModel and
    /// creating Virgil Card instance on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - privateKey: VirgilPrivateKey to self sign with
    ///   - publicKey: Public Key instance
    ///   - identity: Card's identity
    ///   - previousCardId: Identifier of Virgil Card with same identity this Card will replace
    ///   - extraFields: Dictionary with extra data to sign with model. Should be JSON-compatible
    /// - Returns: CallbackOperation<Card> for generating self signed RawSignedModel and
    ///            creating Virgil Card instance on the Virgil Cards Service
    open func publishCard(privateKey: VirgilPrivateKey, publicKey: VirgilPublicKey,
                          identity: String, previousCardId: String? = nil,
                          extraFields: [String: String]? = nil) -> GenericOperation<Card> {
        return CallbackOperation { _, completion in
            do {
                let rawCard = try self.generateRawCard(privateKey: privateKey,
                                                       publicKey: publicKey,
                                                       identity: identity,
                                                       previousCardId: previousCardId,
                                                       extraFields: extraFields)

                let card = try self.publishCard(rawCard: rawCard).startSync().get()

                completion(card, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /// Makes CallbackOperation<[Card]> for performing search of Virgil Cards
    /// on the Virgil Cards Service using identities
    ///
    /// - Note: Resulting array will contain only actual cards.
    ///         Older cards (that were replaced) can be accessed using previousCard property of new cards.
    ///
    /// - Parameter identities: identities of cards to search
    /// - Returns: CallbackOperation<[Card]> for performing search of Virgil Cards
    open func searchCards(identities: [String]) -> GenericOperation<[Card]> {
        return CallbackOperation { _, completion in
            do {
                let cards = try self.cardClient.searchCards(identities: identities)
                    .map { rawSignedModel -> Card in
                        try self.parseCard(from: rawSignedModel)
                    }

                let result = try cards
                    .compactMap { card -> Card? in
                        guard identities.contains(card.identity) else {
                            throw CardManagerError.gotWrongCard
                        }

                        if let nextCard = cards.first(where: { $0.previousCardId == card.identifier }) {
                            nextCard.previousCard = card
                            card.isOutdated = true
                            return nil
                        }

                        return card
                    }

                guard result.allSatisfy({ self.cardVerifier.verifyCard($0) }) else {
                    throw CardManagerError.cardIsNotVerified
                }

                completion(result, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /// Returns list of cards that were replaced with newer ones
    ///
    /// - Parameter cardIds: card ids to check
    /// - Returns: GenericOperation<[String]>
    open func getOutdated(cardIds: [String]) -> GenericOperation<[String]> {
        return CallbackOperation { _, completion in
            do {
                let cardIds = try self.cardClient.getOutdated(cardIds: cardIds)

                completion(cardIds, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /// Makes CallbackOperation<Void> for performing revokation of Virgil Card
    ///
    /// Revoked card gets isOutdated flag to be set to true.
    /// Also, such cards could be obtained using get query, but will be absent in search query result.
    ///
    /// - Parameter cardId: identifier of card to revoke
    /// - Returns: CallbackOperation<Void>
    open func revokeCard(withId cardId: String) -> GenericOperation<Void> {
        return CallbackOperation { _, completion in
            do {
                try self.cardClient.revokeCard(withId: cardId)
                completion(Void(), nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }
}
