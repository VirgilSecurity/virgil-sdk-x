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
    @objc public let modelSigner: ModelSigner
    @objc public let crypto: CardCrypto
    @objc public let accessTokenProvider: AccessTokenProvider
    @objc public let cardClient: CardClient
    @objc public let cardVerifier: CardVerifier
    @objc public let signCallback: ((RawSignedModel)->(RawSignedModel))?
    
    @objc public init(crypto: CardCrypto, accessTokenProvider: AccessTokenProvider, modelSigner: ModelSigner, cardClient: CardClient,  cardVerifier: CardVerifier, signCallback: ((RawSignedModel)->(RawSignedModel))?) {
        self.crypto = crypto
        self.cardClient = cardClient
        self.cardVerifier = cardVerifier
        self.accessTokenProvider = accessTokenProvider
        self.signCallback = signCallback
        self.modelSigner = modelSigner
    }
    
    @objc public enum CardManagerError: Int, Error {
        case cardIsNotValid
        case cardParsingFailed
    }
    
    func verifyCard(_ card: Card) throws {
        guard cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotValid
        }
    }
    
    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey, identity: String, previousCardId: String? = nil, extraFields: [String : String]? = nil) throws -> RawSignedModel {
        let cardContent = RawCardContent(identity: identity, publicKey: try crypto.exportPublicKey(publicKey).base64EncodedString(), previousCardId: nil, createdAt: Date())
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardContent)
        
        var rawCard = RawSignedModel(contentSnapshot: snapshot)
        
        var data: Data?
        if extraFields != nil {
            data = try JSONSerialization.data(withJSONObject: extraFields as Any, options: [])
        }
        
        try self.modelSigner.selfSign(model: rawCard, privateKey: privateKey, additionalData: data)
        
        if let signCallback = self.signCallback {
            rawCard = signCallback(rawCard)
        }
        
        return rawCard
    }
    
    func getToken(operation: String) throws -> AccessToken {
        do {
            return try self.accessTokenProvider.getToken(tokenContext: TokenContext(operation: operation, forceReload: false))
        } catch {
            if let err = error as? CardClient.CardServiceError {
                if err.errorCode == 401 {
                    return try self.accessTokenProvider.getToken(tokenContext: TokenContext(operation: operation, forceReload: true))
                }
            }
            throw error
        }
    }
}


// Import export cards
extension CardManager {
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
    
    @objc public func importCard(rawCard: RawSignedModel) -> Card? {
        return Card.parse(crypto: self.crypto, rawSignedModel: rawCard)
    }
    
    @objc public func exportCardAsString(card: Card) throws -> String {
        return try card.getRawCard(crypto: self.crypto).exportAsString()
    }
    
    @objc public func exportCardAsJson(card: Card) throws -> Any {
        return try card.getRawCard(crypto: self.crypto).exportAsJson()
    }
    
    @objc public func exportAsRawCard(card: Card) throws -> RawSignedModel {
        return try card.getRawCard(crypto: self.crypto)
    }
}
