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
    private let signCallback: ((RawSignedModel)->(RawSignedModel))?
    
    @objc public init(params: CardManagerParams) {
        self.crypto = params.crypto
        self.cardClient = CardClient(baseUrl: params.apiUrl)
        self.cardVerifier = params.cardVerifier
        self.accessTokenProvider = params.accessTokenProvider
        self.signCallback = params.signCallback
    }
    
    private func validateCard(_ card: Card) throws {
        if let cardVerifier = self.cardVerifier {
            let result = cardVerifier.verifyCard(card: card)
            guard result.isValid else {
                throw NSError()
            }
        }
    }
    
    @objc public static let CurrentCardVersion = "5.0"
    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey, previousCardId: String? = nil) throws -> RawSignedModel {
        let token = try self.accessTokenProvider.getToken(forceReload: false)
        
        let cardContent = RawCardContent(identity: token.identity(), publicKeyData: try crypto.exportPublicKey(publicKey), previousCardId: nil, version: CardManager.CurrentCardVersion, createdAt: Date())
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardContent)
        
        var rawCard = RawSignedModel(contentSnapshot: snapshot)
        
        let modelSigner = ModelSigner(crypto: self.crypto)
        
        try modelSigner.selfSign(model: rawCard, privateKey: privateKey)
        
        if let signCallback = self.signCallback {
            rawCard = signCallback(rawCard)
        }
        
        return rawCard
    }
    
    @objc public func getCard(withId cardId: String) throws -> Card {
        let token = try self.accessTokenProvider.getToken(forceReload: false)
        
        let rawSignedModel = try self.cardClient.getCard(withId: cardId, token: token.stringRepresentation())
        guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
            // FIXME
            throw NSError()
        }
        
        try self.validateCard(card)
        
        return card
    }
    
    @objc public func publishCard(rawCard: RawSignedModel) throws -> Card {
        let token = try self.accessTokenProvider.getToken(forceReload: false)
        
        let rawSignedModel = try self.cardClient.publishCard(request: rawCard, token: token.stringRepresentation())
        guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawSignedModel) else {
            // FIXME
            throw NSError()
        }
        
        try self.validateCard(card)
        
        return card
    }
    
    @objc public func publishCard(privateKey: PrivateKey, publicKey: PublicKey, previousCardId: String? = nil) throws -> Card {
        let rawCard = try self.generateRawCard(privateKey: privateKey, publicKey: publicKey, previousCardId: previousCardId)
        
        return try self.publishCard(rawCard: rawCard)
    }
    
    @objc public func searchCards(identity: String) throws -> [Card] {
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
    
    @objc public func importCard(string: String) -> Card? {
        guard let rawCard = RawSignedModel(string: string) else {
            return nil
        }
        
        return Card.parse(crypto: self.crypto, rawSignedModel: rawCard)
    }
    
    @objc public func importCard(json: Any) -> Card? {
        guard let rawCard = RawSignedModel(dict: json) else {
            return nil
        }
        
        return Card.parse(crypto: self.crypto, rawSignedModel: rawCard)
    }
    
    @objc public func exportCardAsString(card: Card) throws -> String {
        return try card.getRawCard(crypto: self.crypto).asString()
    }
    
    @objc public func exportCardAsJson(card: Card) throws -> Any {
        return try card.getRawCard(crypto: self.crypto).asJson()
    }
}
