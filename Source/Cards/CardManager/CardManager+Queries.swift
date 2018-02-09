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
    private func tryPerformQuery<T>(task: (Bool) throws -> T) throws -> T {
        do {
            return try task(false)
        } catch {
            if let err = error as? CardClient.CardServiceError {
                if err.errorCode == 401, self.retryOnUnauthorized {
                    return try task(true)
                }
            }
            throw error
        }
    }

    func getCard(withId cardId: String) -> CallbackOperation<Card> {
        let operation = CallbackOperation<Card> {
            let card: Card = try self.tryPerformQuery { forceReload in
                let tokenContext = TokenContext(operation: "get", forceReload: forceReload)
                let token = try self.accessTokenProvider.getToken(with: tokenContext)

                let responseModel = try self.cardClient.getCard(withId: cardId, token: token.stringRepresentation())

                guard let card = Card.parse(crypto: self.crypto, rawSignedModel: responseModel) else {
                    throw CardManagerError.cardParsingFailed
                }

                try self.verifyCard(card)

                return card
            }
            return card
        }

        return operation
    }

    func publishCard(rawCard: RawSignedModel, token: AccessToken? = nil) -> CallbackOperation<Card> {
        let operation = CallbackOperation<Card> {
            let card: Card = try self.tryPerformQuery { forceReload in
                let tokenContext = TokenContext(operation: "publish", forceReload: forceReload)
                let token = try token ?? self.accessTokenProvider.getToken(with: tokenContext)

                let queue = OperationQueue()
                var rawCard = rawCard
                var error: Error?
                if let signCallback = self.signCallback {
                    queue.addOperation {
                        signCallback(rawCard) { signedRawCard, err in
                            guard let signedRawCard = signedRawCard, err == nil else {
                                error = err
                                return
                            }
                            rawCard = signedRawCard
                        }
                    }
                }
                queue.waitUntilAllOperationsAreFinished()

                if let err = error {
                    throw err
                }

                let responseModel = try self.cardClient.publishCard(model: rawCard, token: token.stringRepresentation())
                guard let card = Card.parse(crypto: self.crypto, rawSignedModel: responseModel) else {
                    throw CardManagerError.cardParsingFailed
                }

                try self.verifyCard(card)

                return card
            }
            return card
        }

        return operation
    }

    func publishCard(privateKey: PrivateKey, publicKey: PublicKey, identity: String?, previousCardId: String? = nil,
                     extraFields: [String: String]? = nil) throws -> CallbackOperation<Card> {
        let tokenContext = TokenContext(operation: "publish", forceReload: false)
        let token = try self.accessTokenProvider.getToken(with: tokenContext)

        let rawCard = try self.generateRawCard(privateKey: privateKey, publicKey: publicKey,
                                               identity: token.identity(), previousCardId: previousCardId,
                                               extraFields: extraFields)

        return self.publishCard(rawCard: rawCard, token: token)
    }

    func searchCards(identity: String) -> CallbackOperation<[Card]> {
        let operation = CallbackOperation<[Card]> {
            let cards: [Card] = try self.tryPerformQuery { forceReload in
                let tokenContext = TokenContext(operation: "search", forceReload: forceReload)
                let token = try self.accessTokenProvider.getToken(with: tokenContext)
                let tokenString = token.stringRepresentation()

                let rawSignedModels = try self.cardClient.searchCards(identity: identity, token: tokenString)

                var cards: [Card] = []
                for rawSignedModel in rawSignedModels {
                    guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
                        throw CardManagerError.cardParsingFailed
                    }
                    cards.append(card)
                }

                cards.forEach { card in
                    let previousCard = cards.first(where: { $0.identifier == card.previousCardId })
                    card.previousCard = previousCard
                    previousCard?.isOutdated = true
                }
                let result = cards.filter { card in cards.filter { $0.previousCard == card }.isEmpty }

                return result
            }
            return cards
        }

        return operation
    }
}

//objc compatable Queries
public extension CardManager {
    @objc func getCard(withId cardId: String, completion: @escaping (Card?, Error?) -> ()) {
        self.getCard(withId: cardId).start { result in
            switch result {
            case .success(let card):
                completion(card, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    @objc func publishCard(rawCard: RawSignedModel, timeout: NSNumber? = nil,
                           completion: @escaping (Card?, Error?) -> ()) {
        self.publishCard(rawCard: rawCard).start { result in
            switch result {
            case .success(let card):
                completion(card, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    @objc func publishCard(privateKey: PrivateKey, publicKey: PublicKey, identity: String,
                           previousCardId: String? = nil, extraFields: [String: String]? = nil,
                           completion: @escaping (Card?, Error?) -> ()) {
        do {
            try self.publishCard(privateKey: privateKey, publicKey: publicKey, identity: identity,
                                 previousCardId: previousCardId, extraFields: extraFields)
            .start { result in
                switch result {
                case .success(let card):
                    completion(card, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        } catch {
            completion(nil, error)
        }
    }

    @objc func searchCards(identity: String, completion: @escaping ([Card]?, Error?) -> ()) {
        self.searchCards(identity: identity).start { result in
            switch result {
            case .success(let cards):
                completion(cards, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
