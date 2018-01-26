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
    @objc public var previousCard: Card?
    @objc public var isOutdated: Bool
    @objc public let version: String
    @objc public let createdAt: Date
    @objc public let signatures: [CardSignature]
    
    private init(identifier: String, identity: String, publicKey: PublicKey, isOutdated: Bool = false, version: String, createdAt: Date, signatures: [CardSignature], previousCardId: String? = nil, previousCard: Card? = nil) {
        self.identifier = identifier
        self.identity = identity
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.previousCard = previousCard
        self.isOutdated = isOutdated
        self.version = version
        self.createdAt = createdAt
        self.signatures = signatures
        
        super.init()
    }
    
    @objc public class func parse(crypto: CardCrypto, rawSignedModel: RawSignedModel) -> Card? {
        guard let rawCardContent: RawCardContent = SnapshotUtils.parseSnapshot(snapshot: rawSignedModel.contentSnapshot) else {
            return nil
        }
        
        guard let publicKeyData = Data(base64Encoded: rawCardContent.publicKey),
              let publicKey = try? crypto.importPublicKey(from: publicKeyData),
              let fingerprint = try? crypto.generateSHA256(for: rawSignedModel.contentSnapshot) else { return nil }
        
        let cardId = fingerprint.hexEncodedString()
        
        var cardSignatures: [CardSignature] = []
        for rawSignature in rawSignedModel.signatures {
            var extraFields: [String : String] = [:]
            var snapshot: String? = nil
            if let rawSnapshot = rawSignature.snapshot,
               let additionalData = Data(base64Encoded: rawSnapshot),
               let json = try? JSONSerialization.jsonObject(with: additionalData, options: []),
               let result = json as? [String : String]
            {
                extraFields = result
                snapshot = rawSnapshot
            }
            guard let signerType = SignerType(from: rawSignature.signerType) else { return nil }
            
            let cardSignature = CardSignature(signerId: rawSignature.signerId, signerType: signerType, signature: rawSignature.signature, snapshot: snapshot, extraFields: extraFields)
            
            cardSignatures.append(cardSignature)
        }
        
        return Card(identifier: cardId, identity: rawCardContent.identity, publicKey: publicKey, version: rawCardContent.version, createdAt: Date(timeIntervalSince1970: TimeInterval(rawCardContent.createdAt)), signatures: cardSignatures, previousCardId: rawCardContent.previousCardId)
    }
    
    @objc public func getRawCard(crypto: CardCrypto) throws -> RawSignedModel {
        let cardContent = RawCardContent(identity: self.identity, publicKey: try crypto.exportPublicKey(self.publicKey).base64EncodedString(), previousCardId: self.previousCardId, version: self.version, createdAt: self.createdAt)
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardContent)
        
        let rawCard = RawSignedModel(contentSnapshot: snapshot)
        
        for cardSignature in self.signatures {
            try rawCard.addSignature(RawSignature(signerId: cardSignature.signerId, snapshot: cardSignature.snapshot, signerType: SignerType(from: cardSignature.signerType)!, signature: cardSignature.signature))
        }
        
        return rawCard
    }
}
