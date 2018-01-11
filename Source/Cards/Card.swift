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
    @objc public let fingerprint: Data
    @objc public let publicKey: PublicKey
    @objc public let previousCardId: String?
    @objc public let version: String
    @objc public let signatures: [CardSignature]
    
    private init(identifier: String, identity: String, fingerprint: Data, publicKey: PublicKey, version: String, signatures: [CardSignature], previousCardId: String?) {
        self.identifier = identifier
        self.identity = identity
        self.fingerprint = fingerprint
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.version = version
        self.signatures = signatures
        
        super.init()
    }
    
    @objc public class func parse(crypto: CardCrypto, rawSignedModel: RawSignedModel) -> Card? {
        guard let rawModelInfo: RawModelInfo = SnapshotUtils.parseSnapshot(snapshot: rawSignedModel.contentSnapshot) else {
            return nil
        }
        
        let fingerprint = crypto.computeSHA256(for: rawSignedModel.contentSnapshot)
        let cardId = fingerprint.hexEncodedString()
        
        guard let publicKey = try? crypto.importPublicKey(from: rawModelInfo.publicKeyData) else {
            return nil
        }
        
        var cardSignatures: [CardSignature] = []
        for rawSignature in rawSignedModel.signatures {
//            let combinedSnapshot = Data(base64Encoded: rawSignature.snapshot)
//            let contentSnapshot = rawSignedModel.contentSnapshot
            
            // FIXME ExtraFields
            let cardSignature = CardSignature.init(signerId: rawSignature.signerId, signerType: rawSignature.signerType, signature: rawSignature.signature)
            
            cardSignatures.append(cardSignature)
        }
        
        return Card(identifier: cardId, identity: rawModelInfo.identity, fingerprint: fingerprint, publicKey: publicKey, version: rawModelInfo.version, signatures: cardSignatures, previousCardId: rawModelInfo.previousCardId)
    }
}
