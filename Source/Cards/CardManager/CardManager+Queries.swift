//
//  CardManager+Queries.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/19/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

// MARK: - Extension for primary operations
extension CardManager {
    /// Makes CallbackOperation<GetCardResponse> for getting `GetCardResponse` with verified Virgil Card
    /// from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameter cardId: identifier of Virgil Card to find
    /// - Returns: CallbackOperation<GetCardResponse> for getting `GetCardResponse` with verified Virgil Card
    open func getCard(withId cardId: String) -> CallbackOperation<Card> {
        let aggregateOperation = CallbackOperation<Card> { _, completion in
            let tokenContext = TokenContext(operation: "get", forceReload: false)
            let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
            let getCardOperation = self.makeGetCardOperation(cardId: cardId)
            let verifyCardOperation = self.makeVerifyCardOperation()

            getCardOperation.addDependency(getTokenOperation)
            verifyCardOperation.addDependency(getCardOperation)

            verifyCardOperation.completionBlock = { [unowned verifyCardOperation] in
                do {
                    guard let verifyResult = verifyCardOperation.result,
                        case let .success(verified) = verifyResult,
                        verified else {
                            throw CardManagerError.cardIsNotVerified
                    }

                    let card: Card = try verifyCardOperation.findDependencyResult()
                    completion(card, nil)
                }
                catch {
                    completion(nil, error)
                }
            }

            let queue = OperationQueue()
            queue.addOperations([getTokenOperation, getCardOperation, verifyCardOperation], waitUntilFinished: false)
        }

        return aggregateOperation
    }

    /// Generates self signed RawSignedModel
    ///
    /// - Parameters:
    ///   - privateKey: PrivateKey to self sign with
    ///   - publicKey: Public Key instance
    ///   - identity: Card's identity
    ///   - previousCardId: Identifier of Virgil Card with same identity this Card will replace
    ///   - extraFields: Dictionary with extra data to sign with model. Should be JSON-compatible
    /// - Returns: Self signed RawSignedModel
    /// - Throws: Rethrows from CardCrypto, JSONEncoder, JSONSerialization, ModelSigner
    @objc open func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey,
                                    identity: String, previousCardId: String? = nil,
                                    extraFields: [String: String]? = nil) throws -> RawSignedModel {
        let exportedPubKey = try self.cardCrypto.exportPublicKey(publicKey)

        let cardContent = RawCardContent(identity: identity, publicKey: exportedPubKey,
                                         previousCardId: previousCardId, createdAt: Date())

        let snapshot = try JSONEncoder().encode(cardContent)

        let rawCard = RawSignedModel(contentSnapshot: snapshot)

        var data: Data?
        if extraFields != nil {
            data = try JSONSerialization.data(withJSONObject: extraFields as Any, options: [])
        }
        else {
            data = nil
        }

        try self.modelSigner.selfSign(model: rawCard, privateKey: privateKey, additionalData: data)

        return rawCard
    }

    /// Makes CallbackOperation<Card> for creating Virgil Card instance
    /// on the Virgil Cards Service and associates it with unique identifier
    ///
    /// - Parameter rawCard: RawSignedModel of Card to create
    /// - Returns: CallbackOperation<Card> for creating Virgil Card instance
    open func publishCard(rawCard: RawSignedModel) -> CallbackOperation<Card> {
        let aggregateOperation = CallbackOperation<Card> { _, completion in
            let tokenContext = TokenContext(operation: "publish", forceReload: false)
            let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
            let generateRawCardOperation = CallbackOperation<RawSignedModel> { _, completion in
                completion(rawCard, nil)
            }
            let publishCardOperation = self.makePublishCardOperation()
            let verifyCardOperation = self.makeVerifyCardOperation()

            generateRawCardOperation.addDependency(getTokenOperation)
            publishCardOperation.addDependency(getTokenOperation)
            publishCardOperation.addDependency(generateRawCardOperation)
            verifyCardOperation.addDependency(publishCardOperation)

            verifyCardOperation.completionBlock = { [unowned verifyCardOperation] in
                do {
                    guard let verifyResult = verifyCardOperation.result,
                        case let .success(verified) = verifyResult,
                        verified else {
                            throw CardManagerError.cardIsNotVerified
                    }

                    let card: Card = try verifyCardOperation.findDependencyResult()
                    completion(card, nil)
                }
                catch {
                    completion(nil, error)
                }
            }

            let queue = OperationQueue()
            let operations = [getTokenOperation, generateRawCardOperation, publishCardOperation, verifyCardOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }

        return aggregateOperation
    }

    /// Makes CallbackOperation<Card> for generating self signed RawSignedModel and
    /// creating Virgil Card instance on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - privateKey: PrivateKey to self sign with
    ///   - publicKey: Public Key instance
    ///   - identity: Card's identity
    ///   - previousCardId: Identifier of Virgil Card with same identity this Card will replace
    ///   - extraFields: Dictionary with extra data to sign with model. Should be JSON-compatible
    /// - Returns: CallbackOperation<Card> for generating self signed RawSignedModel and
    ///            creating Virgil Card instance on the Virgil Cards Service
    open func publishCard(privateKey: PrivateKey, publicKey: PublicKey,
                          identity: String? = nil, previousCardId: String? = nil,
                          extraFields: [String: String]? = nil) -> GenericOperation<Card> {
        let aggregateOperation = CallbackOperation<Card> { operation, completion in
            let tokenContext = TokenContext(operation: "publish", forceReload: false)
            let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
            let generateRawCardOperation = CallbackOperation<RawSignedModel> { operation, completion in
                do {
                    let token: AccessToken = try operation.findDependencyResult()

                    let rawCard = try self.generateRawCard(privateKey: privateKey, publicKey: publicKey,
                                                           identity: token.identity(), previousCardId: previousCardId,
                                                           extraFields: extraFields)

                    completion(rawCard, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
            let publishCardOperation = self.makePublishCardOperation()
            let verifyCardOperation = self.makeVerifyCardOperation()

            generateRawCardOperation.addDependency(getTokenOperation)
            publishCardOperation.addDependency(getTokenOperation)
            publishCardOperation.addDependency(generateRawCardOperation)
            verifyCardOperation.addDependency(publishCardOperation)

            verifyCardOperation.completionBlock = { [unowned verifyCardOperation] in
                do {
                    guard let verifyResult = verifyCardOperation.result,
                        case let .success(verified) = verifyResult,
                        verified else {
                            throw CardManagerError.cardIsNotVerified
                    }

                    let card: Card = try verifyCardOperation.findDependencyResult()
                    completion(card, nil)
                }
                catch {
                    completion(nil, error)
                }
            }

            let queue = OperationQueue()
            let operations = [getTokenOperation, generateRawCardOperation, publishCardOperation, verifyCardOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }

        return aggregateOperation
    }

    /// Makes CallbackOperation<[Card]> for performing search of Virgil Cards
    /// using identity on the Virgil Cards Service
    ///
    /// NOTE: Resulting array will contain only actual cards.
    ///       Older cards (that were replaced) can be accessed using previousCard property of new cards.
    ///
    /// - Parameter identity: identity of cards to search
    /// - Returns: CallbackOperation<[Card]> for performing search of Virgil Cards
    open func searchCards(identity: String) -> CallbackOperation<[Card]> {
        let aggregateOperation = CallbackOperation<[Card]> { _, completion in
            let tokenContext = TokenContext(operation: "search", forceReload: false)
            let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
            let searchCardsOperation = self.makeSearchCardsOperation(identity: identity)
            let verifyCardsOperation = self.makeVerifyCardsOperation()

            searchCardsOperation.addDependency(getTokenOperation)
            verifyCardsOperation.addDependency(searchCardsOperation)

            verifyCardsOperation.completionBlock = { [unowned verifyCardsOperation] in
                do {
                    guard let verifyResult = verifyCardsOperation.result,
                        case let .success(verified) = verifyResult,
                        verified else {
                            throw CardManagerError.cardIsNotVerified
                    }

                    let cards: [Card] = try verifyCardsOperation.findDependencyResult()

                    guard !cards.contains(where: { $0.identity != identity }) else {
                        throw CardManagerError.gotWrongCard
                    }

                    completion(cards, nil)
                }
                catch {
                    completion(nil, error)
                }
            }

            let queue = OperationQueue()
            let operations = [getTokenOperation, searchCardsOperation, verifyCardsOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }

        return aggregateOperation
    }
}
