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
    public let identifier: String
    public let identity: String
    public let fingerprint: Data
    public let publicKey: PublicKey
    public let version: String
    public let signatures: [CardSignature]
    
    private init(identifier: String, identity: String, fingerprint: Data, publicKey: PublicKey, version: String, signatures: [CardSignature]) {
        self.identifier = identifier
        self.identity = identity
        self.fingerprint = fingerprint
        self.publicKey = publicKey
        self.version = version
        self.signatures = signatures
        
        super.init()
    }
    
    public class func parse(crypto: Crypto, rawCard: RawCard) -> Card? {
        guard let rawCardInfo: RawCardInfo = SnapshotUtils.parseSnapshot(snapshot: rawCard.contentSnapshot) else {
            return nil
        }
        
        let fingerprint = crypto.computeSHA256(for: rawCard.contentSnapshot)
        let cardId = fingerprint.hexEncodedString()
        
        guard let publicKey = try? crypto.importPublicKey(from: rawCardInfo.publicKeyData) else {
            return nil
        }
        
        return Card(identifier: cardId, identity: rawCardInfo.identity, fingerprint: fingerprint, publicKey: publicKey, version: rawCardInfo.version, signatures: rawCard.signatures)
    }
}
