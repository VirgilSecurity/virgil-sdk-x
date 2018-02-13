//
//  CardManager+Operations.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

extension CardManager {
    internal func makeVerifyCardOperation() -> GenericOperation<Bool> {
        return CallbackOperation<Bool> { operation, completion in
            do {
                let card: Card = try operation.findDependencyResult()

                completion(self.cardVerifier.verifyCard(card: card), nil)
            }
            catch {
                completion(false, nil)
            }
        }
    }

    internal func makeVerifyCardsOperation() -> GenericOperation<Bool> {
        return CallbackOperation<Bool> { operation, completion in
            do {
                let cards: [Card] = try operation.findDependencyResult()

                for card in cards {
                    guard self.cardVerifier.verifyCard(card: card) else {
                        completion(false, nil)
                        return
                    }
                }

                completion(true, nil)
            }
            catch {
                completion(false, nil)
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

                guard let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: responseModel.rawCard) else {
                    throw CardManagerError.cardIsCorrupted
                }
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

                guard let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: responseModel) else {
                    throw CardManagerError.cardIsCorrupted
                }

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
                    guard let card = Card.parse(cardCrypto: self.cardCrypto, rawSignedModel: rawSignedModel) else {
                        throw CardManagerError.cardIsCorrupted
                    }
                    cards.append(card)
                }

                cards.forEach { card in
                    let previousCard = cards.first(where: { $0.identifier == card.previousCardId })
                    card.previousCard = previousCard
                    previousCard?.isOutdated = true
                }
                let result = cards.filter { card in cards.filter { $0.previousCard == card }.isEmpty }

                completion(result, nil)
            }
            catch {
                completion(nil, error)
            }
        }

        return searchCardsOperation
    }
}
