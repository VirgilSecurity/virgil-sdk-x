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
    @objc public let cardVerifier: CardVerifier?
    @objc public let signCallback: ((RawSignedModel)->(RawSignedModel))?
    
    @objc public init(params: CardManagerParams) {
        self.crypto = params.crypto
        self.cardClient = CardClient(serviceUrl: params.serviceUrl)
        self.cardVerifier = params.cardVerifier
        self.accessTokenProvider = params.accessTokenProvider
        self.signCallback = params.signCallback
        self.modelSigner = params.modelSigner
    }
    
    @objc public enum CardManagerError: Int, Error {
        case cardIsNotValid
        case cardParsingFailed
    }
    
    func validateCard(_ card: Card) throws {
        if let cardVerifier = self.cardVerifier {
            let result = cardVerifier.verifyCard(card: card)
            guard result.isValid else {
                throw CardManagerError.cardIsNotValid
            }
        }
    }
    
    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey, identity: String, previousCardId: String? = nil, extraFields: [String:String]? = nil) throws -> RawSignedModel {
        let cardContent = RawCardContent(identity: identity, publicKey: try crypto.exportPublicKey(publicKey).base64EncodedString(), previousCardId: nil, createdAt: Date())
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardContent)
        
        var rawCard = RawSignedModel(contentSnapshot: snapshot)
        
        try self.modelSigner.selfSign(model: rawCard, privateKey: privateKey)
        
        if let signCallback = self.signCallback {
            rawCard = signCallback(rawCard)
        }
        
        return rawCard
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
