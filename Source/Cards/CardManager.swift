//
//  CardManager.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCardManager) public class CardManager: NSObject {
    private let crypto: CardCrypto
    private let accessTokenProvider: AccessTokenProvider
    private let cardClient: CardClient
    private let cardVerifier: CardVerifier?
    
    @objc public init(params: CardManagerParams) {
        self.crypto = params.crypto
        self.cardClient = CardClient(baseUrl: params.apiUrl)
        self.cardVerifier = params.cardVerifier
        self.accessTokenProvider = params.accessTokenProvider
    }
    
    private func validateCard(_ card: Card) throws {
        if let cardVerifier = self.cardVerifier {
            let result = cardVerifier.verifyCard(card: card)
            guard result.isValid else {
                throw NSError()
            }
        }
    }
    
    @objc public func getCard(withId cardId: String) throws -> Card {
        let token = self.accessTokenProvider.getToken(forceReload: false)
        let rawSignedModel = try self.cardClient.getCard(withId: cardId, token: token.stringRepresentation())
        guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
            // FIXME
            throw NSError()
        }
        
        try self.validateCard(card)
        
        return card
    }
    
    @objc public func publishCard(csr: CSR) throws -> Card {
        let token = self.accessTokenProvider.getToken(forceReload: false)
        let rawSignedModel = try self.cardClient.publishCard(request: csr.rawCard, token: token.stringRepresentation())
        guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
            // FIXME
            throw NSError()
        }
        
        try self.validateCard(card)
        
        return card
    }
    
    @objc public func searchCards(withId identity: String) throws -> [Card] {
        let token = self.accessTokenProvider.getToken(forceReload: false)
        let rawSignedModels = try self.cardClient.searchCards(identity: identity, token: token.stringRepresentation())
        
        var result: [Card] = []
        for rawSignedModel in rawSignedModels {
            guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
                // FIXME
                throw NSError()
            }
            result.append(card)
        }
        
        return result
    }
}
