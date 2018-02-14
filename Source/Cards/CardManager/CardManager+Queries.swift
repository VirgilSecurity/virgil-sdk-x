//
//  CardManager+Queries.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/19/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

public extension CardManager {
    /// Makes CallbackOperation<GetCardResponse> for getting `GetCardResponse` with verified Virgil Card
    /// from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameter cardId: identifier of Virgil Card to find
    /// - Returns: CallbackOperation<GetCardResponse> for getting `GetCardResponse` with verified Virgil Card
    func getCard(withId cardId: String) -> CallbackOperation<Card> {
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

    /// Makes CallbackOperation<Card> for creating Virgil Card instance
    /// on the Virgil Cards Service and associates it with unique identifier
    ///
    /// - Important: `RawSignedModel` should be at least selfSigned
    ///
    /// - Parameter rawCard: RawSigned model of Card to create
    /// - Returns: CallbackOperation<Card> for creating Virgil Card instance
    func publishCard(rawCard: RawSignedModel) -> CallbackOperation<Card> {
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
    ///   - privateKey: Private Key to self sign RawSignedModel with
    ///   - publicKey: PublicKey for generating RawSignedModel
    ///   - identity: identity for generating RawSignedModel. Will be taken from token if ommited
    ///   - previousCardId: identifier of Virgil Card to replace
    ///   - extraFields: Dictionary with extra data to sign with model
    /// - Returns: CallbackOperation<Card> for generating self signed RawSignedModel and
    ///            creating Virgil Card instance on the Virgil Cards Service
    /// - Throws: corresponding Error
    func publishCard(privateKey: PrivateKey, publicKey: PublicKey,
                     identity: String? = nil, previousCardId: String? = nil,
                     extraFields: [String: String]? = nil) throws -> GenericOperation<Card> {
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
    /// - Parameter identity: identity of cards to search
    /// - Returns: CallbackOperation<[Card]> for performing search of Virgil Cards
    func searchCards(identity: String) -> CallbackOperation<[Card]> {
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
