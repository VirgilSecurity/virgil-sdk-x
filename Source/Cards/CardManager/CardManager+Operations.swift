//
// Copyright (C) 2015-2018 Virgil Security Inc.
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
import VirgilCryptoAPI

extension CardManager {
    internal func makeEmptyOperation() -> GenericOperation<Void> {
        return CallbackOperation { _, completion in
            completion(Void(), nil)
        }
    }

    internal func makeCompletionOperation<T>(completion: @escaping (T?, Error?) -> Void) -> GenericOperation<Void> {
        let completionOperation = CallbackOperation { _, completion in
            completion(Void(), nil)
        }

        completionOperation.completionBlock = {
            do {
                if let error = completionOperation.findDependencyError() {
                    completion(nil, error)
                    return
                }

                let res: T = try completionOperation.findDependencyResult()
                completion(res, nil)
            }
            catch {
                completion(nil, error)
            }
        }

        return completionOperation
    }

    private func makeRetryOperation(aggregateOperation: Operation,
                                    makeAggregateOperation: @escaping (Bool) -> Operation,
                                    completionOperation: Operation,
                                    queue: OperationQueue) -> GenericOperation<Void> {
        let retryCheckOp = CallbackOperation<Void> { [unowned completionOperation, queue] operation, completion in
            if let error = operation.findDependencyError(),
                let cardServiceError = error as? CardServiceError,
                cardServiceError.errorCode == 20304 {
                let aggregateOperationRetry = makeAggregateOperation(true)
                completionOperation.addDependency(aggregateOperationRetry)
                completionOperation.removeDependency(aggregateOperation)
                queue.addOperation(aggregateOperationRetry)
                completion(Void(), nil)
            }

            completion(Void(), nil)
        }

        return retryCheckOp
    }

    internal func makeRetryAggregate<T>(
        makeAggregateOperation: @escaping (Bool) -> GenericOperation<T>)-> GenericOperation<T> {
        return CallbackOperation<T> { _, completion in
            let queue = OperationQueue()

            let aggregateOperation = makeAggregateOperation(false)
            let completionOperation = self.makeCompletionOperation(completion: completion)
            let retryCheckOperation =
                self.makeRetryOperation(aggregateOperation: aggregateOperation,
                                        makeAggregateOperation: makeAggregateOperation,
                                        completionOperation: completionOperation, queue: queue)

            retryCheckOperation.addDependency(aggregateOperation)

            completionOperation.addDependency(aggregateOperation)
            completionOperation.addDependency(retryCheckOperation)

            let operations = [aggregateOperation, retryCheckOperation, completionOperation]
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }

    internal func makeVerifyCardOperation() -> GenericOperation<Void> {
        return CallbackOperation<Void> { operation, completion in
            do {
                let card: Card = try operation.findDependencyResult()

                guard self.cardVerifier.verifyCard(card) else {
                    throw CardManagerError.cardIsNotVerified
                }

                completion(Void(), nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    internal func makeVerifyCardsOperation() -> GenericOperation<Void> {
        return CallbackOperation<Void> { operation, completion in
            do {
                let cards: [Card] = try operation.findDependencyResult()

                for card in cards {
                    guard self.cardVerifier.verifyCard(card) else {
                        throw CardManagerError.cardIsNotVerified
                    }
                }

                completion(Void(), nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    internal func makeGetTokenOperation(tokenContext: TokenContext) -> GenericOperation<AccessToken> {
        return CallbackOperation<AccessToken> { _, completion in
            self.accessTokenProvider.getToken(with: tokenContext, completion: completion)
        }
    }

    internal func makeGetCardOperation(cardId: String) -> GenericOperation<Card> {
        let getCardOperation = CallbackOperation<Card> { operation, completion in
            do {
                let token: AccessToken = try operation.findDependencyResult()

                let responseModel = try self.cardClient.getCard(withId: cardId, token: token.stringRepresentation())

                let card = try self.parseCard(from: responseModel.rawCard)
                card.isOutdated = responseModel.isOutdated

                guard card.identifier == cardId else {
                    throw CardManagerError.gotWrongCard
                }

                completion(card, nil)
            }
            catch {
                completion(nil, error)
            }
        }

        return getCardOperation
    }

    internal func makePublishCardOperation() -> GenericOperation<Card> {
        let publishCardOperation = CallbackOperation<Card> { operation, completion in
            do {
                let token: AccessToken = try operation.findDependencyResult()
                let rawCard: RawSignedModel = try operation.findDependencyResult()

                let responseModel = try self.cardClient.publishCard(model: rawCard, token: token.stringRepresentation())

                guard responseModel.contentSnapshot == rawCard.contentSnapshot,
                    let selfSignature = rawCard.signatures
                        .first(where: { $0.signer == ModelSigner.selfSignerIdentifier }),
                    let responseSelfSignature = responseModel.signatures
                        .first(where: { $0.signer == ModelSigner.selfSignerIdentifier }),
                    selfSignature.snapshot == responseSelfSignature.snapshot else {
                    throw CardManagerError.gotWrongCard
                }

                let card = try self.parseCard(from: responseModel)

                completion(card, nil)
            }
            catch {
                completion(nil, error)
            }
        }

        return publishCardOperation
    }

    internal func makeSearchCardsOperation(identity: String) -> GenericOperation<[Card]> {
        let searchCardsOperation = CallbackOperation<[Card]> { operation, completion in
            do {
                let token: AccessToken = try operation.findDependencyResult()

                let rawSignedModels = try self.cardClient.searchCards(identity: identity,
                                                                      token: token.stringRepresentation())

                var cards: [Card] = []
                for rawSignedModel in rawSignedModels {
                    let card = try self.parseCard(from: rawSignedModel)

                    cards.append(card)
                }

                try cards.forEach { card in
                    guard card.identity == identity else {
                        throw CardManagerError.gotWrongCard
                    }

                    let previousCard = cards.first(where: { $0.identifier == card.previousCardId })
                    card.previousCard = previousCard
                    previousCard?.isOutdated = true
                }
                let result = cards.filter { card in cards.filter { $0.previousCard === card }.isEmpty }

                completion(result, nil)
            }
            catch {
                completion(nil, error)
            }
        }

        return searchCardsOperation
    }

    internal func makeAdditionalSignOperation() -> GenericOperation<RawSignedModel> {
        let signOperation = CallbackOperation<RawSignedModel> { operation, completion in
            do {
                let rawCard: RawSignedModel = try operation.findDependencyResult()

                if let signCallback = self.signCallback {
                    signCallback(rawCard) { rawCard, error in
                        completion(rawCard, error)
                    }
                }
                else {
                    completion(rawCard, nil)
                }
            }
            catch {
                completion(nil, error)
            }
        }

        return signOperation
    }

    internal func makeGenerateRawCardOperation(rawCard: RawSignedModel) -> GenericOperation<RawSignedModel> {
        let generateRawCardOperation = CallbackOperation<RawSignedModel> { _, completion in
            completion(rawCard, nil)
        }

        return generateRawCardOperation
    }

    internal func makeGenerateRawCardOperation(privateKey: PrivateKey,
                                               publicKey: PublicKey,
                                               previousCardId: String?,
                                               extraFields: [String: String]?) -> GenericOperation<RawSignedModel> {
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

        return generateRawCardOperation
    }
}
