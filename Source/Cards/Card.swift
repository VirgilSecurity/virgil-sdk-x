//
//  Card.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCard) public class Card: NSObject {
    @objc public let identifier: String
    @objc public let identity: String
    @objc public let publicKey: PublicKey
    @objc public let previousCardId: String?
    @objc public let version: String
    @objc public let createdAt: Date
    @objc public let signatures: [CardSignature]
    
    private init(identifier: String, identity: String, publicKey: PublicKey, version: String, createdAt: Date, signatures: [CardSignature], previousCardId: String? = nil) {
        self.identifier = identifier
        self.identity = identity
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.version = version
        self.createdAt = createdAt
        self.signatures = signatures
        
        super.init()
    }
    
    @objc public class func parse(crypto: CardCrypto, rawSignedModel: RawSignedModel) -> Card? {
        guard let rawCardContent: RawCardContent = SnapshotUtils.parseSnapshot(snapshot: rawSignedModel.contentSnapshot) else {
            return nil
        }
        
        let fingerprint = crypto.computeSHA256(for: rawSignedModel.contentSnapshot)
        let cardId = fingerprint.hexEncodedString()
        
        guard let publicKey = try? crypto.importPublicKey(from: rawCardContent.publicKeyData) else {
            return nil
        }
        
        var cardSignatures: [CardSignature] = []
        for rawSignature in rawSignedModel.signatures {
            var extraFields: [String : Any] = [:]
            if let additionalData = Data(base64Encoded: rawSignature.snapshot),
               let json = try? JSONSerialization.jsonObject(with: additionalData, options: []),
               let result = json as? [String : Any]
            {
                extraFields = result
            }
            
            let cardSignature = CardSignature(signerId: rawSignature.signerId, signerType: rawSignature.signerType, signature: rawSignature.signature, snapshot: rawSignature.snapshot, extraFields: extraFields)
            
            cardSignatures.append(cardSignature)
        }
        
        return Card(identifier: cardId, identity: rawCardContent.identity, publicKey: publicKey, version: rawCardContent.version, createdAt: rawCardContent.createdAt, signatures: cardSignatures, previousCardId: rawCardContent.previousCardId)
    }
    
    @objc public func getRawCard(crypto: CardCrypto) throws -> RawSignedModel {
        let cardContent = RawCardContent(identity: self.identity, publicKeyData: try crypto.exportPublicKey(self.publicKey), previousCardId: self.previousCardId, version: self.version, createdAt: self.createdAt)
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardContent)
        
        let rawCard = RawSignedModel(contentSnapshot: snapshot)
        
        for cardSignature in self.signatures {
            rawCard.signatures.append(RawSignature(signerId: cardSignature.signerId, snapshot: cardSignature.snapshot, signerType: cardSignature.signerType, signature: cardSignature.signature))
        }
        
        return rawCard
    }
}
