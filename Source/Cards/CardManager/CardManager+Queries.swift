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

    func publishCard(privateKey: PrivateKey, publicKey: PublicKey, identity: String?, previousCardId: String? = nil,
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
