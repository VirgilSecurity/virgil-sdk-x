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
    open func getCard(withId cardId: String) -> GenericOperation<Card> {
        let makeAggregateOperation: (Bool) -> GenericOperation<Card> = { force in
            return CallbackOperation() { _, completion in
                let tokenContext = TokenContext(operation: "get", forceReload: force)
                let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
                let getCardOperation = self.makeGetCardOperation(cardId: cardId)
                let verifyCardOperation = self.makeVerifyCardOperation()
                let completionOperation = self.makeCompletionOperation(completion: completion)
                
                getCardOperation.addDependency(getTokenOperation)
                verifyCardOperation.addDependency(getCardOperation)
                
                completionOperation.addDependency(getTokenOperation)
                completionOperation.addDependency(getCardOperation)
                completionOperation.addDependency(verifyCardOperation)
                
                let queue = OperationQueue()
                let operations = [getTokenOperation, getCardOperation, verifyCardOperation, completionOperation]
                queue.addOperations(operations, waitUntilFinished: false)
            }
        }
        
        if !self.retryOnUnauthorized {
            return makeAggregateOperation(false)
        }
        else {
            return self.makeRetryAggregate(makeAggregateOperation: makeAggregateOperation)
        }
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
    open func publishCard(rawCard: RawSignedModel) -> GenericOperation<Card> {
        let makeAggregateOperation: (Bool) -> GenericOperation<Card> = { forceReload in
            return CallbackOperation() { _, completion in
                let tokenContext = TokenContext(operation: "publish", forceReload: forceReload)
                let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
                let generateRawCardOperation = self.makeGenerateRawCardOperation(rawCard: rawCard)
                let signOperation = self.makeAdditionalSignOperation()
                let publishCardOperation = self.makePublishCardOperation()
                let verifyCardOperation = self.makeVerifyCardOperation()
                let completionOperation = self.makeCompletionOperation(completion: completion)
                
                generateRawCardOperation.addDependency(getTokenOperation)
                signOperation.addDependency(generateRawCardOperation)
                publishCardOperation.addDependency(getTokenOperation)
                publishCardOperation.addDependency(signOperation)
                verifyCardOperation.addDependency(publishCardOperation)
                
                completionOperation.addDependency(getTokenOperation)
                completionOperation.addDependency(generateRawCardOperation)
                completionOperation.addDependency(signOperation)
                completionOperation.addDependency(publishCardOperation)
                completionOperation.addDependency(verifyCardOperation)
                
                let queue = OperationQueue()
                let operations = [getTokenOperation, generateRawCardOperation, signOperation,
                                  publishCardOperation, verifyCardOperation, completionOperation]
                queue.addOperations(operations, waitUntilFinished: false)
            }
        }
        
        if !self.retryOnUnauthorized {
            return makeAggregateOperation(false)
        }
        else {
            return self.makeRetryAggregate(makeAggregateOperation: makeAggregateOperation)
        }
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
        let makeAggregateOperation: (Bool) -> GenericOperation<Card> = { forceReload in
            return CallbackOperation() { operation, completion in
                let tokenContext = TokenContext(operation: "publish", forceReload: forceReload)
                let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
                let generateRawCardOperation =
                    self.makeGenerateRawCardOperation(privateKey: privateKey, publicKey: publicKey,
                                                      previousCardId: previousCardId, extraFields: extraFields)
                let signOperation = self.makeAdditionalSignOperation()
                let publishCardOperation = self.makePublishCardOperation()
                let verifyCardOperation = self.makeVerifyCardOperation()
                let completionOperation = self.makeCompletionOperation(completion: completion)
                
                generateRawCardOperation.addDependency(getTokenOperation)
                signOperation.addDependency(generateRawCardOperation)
                publishCardOperation.addDependency(getTokenOperation)
                publishCardOperation.addDependency(signOperation)
                verifyCardOperation.addDependency(publishCardOperation)
                
                completionOperation.addDependency(getTokenOperation)
                completionOperation.addDependency(generateRawCardOperation)
                completionOperation.addDependency(signOperation)
                completionOperation.addDependency(publishCardOperation)
                completionOperation.addDependency(verifyCardOperation)
                
                let queue = OperationQueue()
                let operations = [getTokenOperation, generateRawCardOperation, signOperation,
                                  publishCardOperation, verifyCardOperation, completionOperation]
                queue.addOperations(operations, waitUntilFinished: false)
            }
        }
        
        if !self.retryOnUnauthorized {
            return makeAggregateOperation(false)
        }
        else {
            return self.makeRetryAggregate(makeAggregateOperation: makeAggregateOperation)
        }
    }

    /// Makes CallbackOperation<[Card]> for performing search of Virgil Cards
    /// using identity on the Virgil Cards Service
    ///
    /// NOTE: Resulting array will contain only actual cards.
    ///       Older cards (that were replaced) can be accessed using previousCard property of new cards.
    ///
    /// - Parameter identity: identity of cards to search
    /// - Returns: CallbackOperation<[Card]> for performing search of Virgil Cards
    open func searchCards(identity: String) -> GenericOperation<[Card]> {
        let makeAggregateOperation: (Bool) -> GenericOperation<[Card]> = { forceReload in
            return CallbackOperation() { _, completion in
                let tokenContext = TokenContext(operation: "search", forceReload: forceReload)
                let getTokenOperation = self.makeGetTokenOperation(tokenContext: tokenContext)
                let searchCardsOperation = self.makeSearchCardsOperation(identity: identity)
                let verifyCardsOperation = self.makeVerifyCardsOperation()
                let completionOperation = self.makeCompletionOperation(completion: completion)
                
                searchCardsOperation.addDependency(getTokenOperation)
                verifyCardsOperation.addDependency(searchCardsOperation)
                
                completionOperation.addDependency(getTokenOperation)
                completionOperation.addDependency(searchCardsOperation)
                completionOperation.addDependency(verifyCardsOperation)
                
                let queue = OperationQueue()
                let operations = [getTokenOperation, searchCardsOperation, verifyCardsOperation, completionOperation]
                queue.addOperations(operations, waitUntilFinished: false)
            }
        }
        
        if !self.retryOnUnauthorized {
            return makeAggregateOperation(false)
        }
        else {
            return self.makeRetryAggregate(makeAggregateOperation: makeAggregateOperation)
        }
    }
}
