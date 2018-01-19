//
//  CardManager+Queries.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/19/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

extension CardManager {
    public func getCard(withId cardId: String) -> CallbackOperation<Card> {
        let operation = CallbackOperation<Card>() {
            let token = try self.accessTokenProvider.getToken(forceReload: false)
            
            let rawSignedModel = try self.cardClient.getCard(withId: cardId, token: token.stringRepresentation())
            guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
                // FIXME
                throw NSError()
            }
            
            try self.validateCard(card)
            
            return card
        }
        
        return operation
    }
    
    public func publishCard(rawCard: RawSignedModel) -> CallbackOperation<Card> {
        let operation = CallbackOperation<Card>() {
            let token = try self.accessTokenProvider.getToken(forceReload: false)
            
            let rawSignedModel = try self.cardClient.publishCard(request: rawCard, token: token.stringRepresentation())
            guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
                // FIXME
                throw NSError()
            }
            
            try self.validateCard(card)
            
            return card
        }
        
        return operation
    }
    
    public func publishCard(privateKey: PrivateKey, publicKey: PublicKey, previousCardId: String? = nil) throws -> CallbackOperation<Card> {
        let rawCard = try self.generateRawCard(privateKey: privateKey, publicKey: publicKey, previousCardId: previousCardId)
        
        return self.publishCard(rawCard: rawCard)
    }
    
    public func searchCards(identity: String) -> CallbackOperation<[Card]> {
        let operation = CallbackOperation<[Card]>() {
            let token = try self.accessTokenProvider.getToken(forceReload: false)
            
            let rawSignedModels = try self.cardClient.searchCards(identity: identity, token: token.stringRepresentation())
            
            var cards: [Card] = []
            for rawSignedModel in rawSignedModels {
                guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
                    // FIXME
                    throw NSError()
                }
                cards.append(card)
            }
            
            cards.forEach { card in
                let previousCard = cards.first(where: { $0.identifier == card.previousCardId })
                card.previousCard = previousCard
                previousCard?.isOutdated = true
            }
            let result = cards.filter { card in cards.filter{ $0.previousCard == card}.count == 0 }
            
            return result
        }
        
        return operation
    }
}

//objc compatable Queries
extension CardManager {
    @objc public func getCard(withId cardId: String, timeout: NSNumber? = nil, completion: @escaping (Card?, Error?)->()) {
        self.getCard(withId: cardId).start(timeout: timeout as? Int) { result in
            switch result {
            case .success(let card):
                completion(card, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func publishCard(rawCard: RawSignedModel, timeout: NSNumber? = nil, completion: @escaping (Card?, Error?)->()) {
        self.publishCard(rawCard: rawCard).start(timeout: timeout as? Int) { result in
            switch result {
            case .success(let card):
                completion(card, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func publishCard(privateKey: PrivateKey, publicKey: PublicKey, previousCardId: String? = nil,
                                  timeout: NSNumber? = nil, completion: @escaping (Card?, Error?)->())
    {
        do {
            try self.publishCard(privateKey: privateKey, publicKey: publicKey, previousCardId: previousCardId).start(timeout: timeout as? Int) { result in
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
    
    @objc public func searchCards(identity: String, timeout: NSNumber? = nil, completion: @escaping ([Card]?, Error?)->()) {
        self.searchCards(identity: identity).start(timeout: timeout as? Int) { result in
            switch result {
            case .success(let cards):
                completion(cards, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

