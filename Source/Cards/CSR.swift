//
//  CSR.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCSR) public class CSR: NSObject {
    private let info: RawCardInfo
    private let snapshot: Data
    private let signatures: [CardSignature]
    
    private init(info: RawCardInfo, snapshot: Data, signatures: [CardSignature]) {
        self.info = info
        self.snapshot = snapshot
        self.signatures = signatures
        
        super.init()
    }
    
    public var rawCard: RawCard {
        return RawCard(contentSnapshot: self.snapshot, signatures: self.signatures)
    }
    
    public func sign(crypto: Crypto, params: SignParams) {
        
    }
    
    // EXPORT
    // IMPORT
    
    public class func generate(crypto: Crypto, params: CSRParams) throws -> CSR {
        let cardInfo = RawCardInfo(identity: params.identity, publicKeyData: try crypto.exportPublicKey(params.publicKey), version: "5.0")
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardInfo)
        
        let csr = CSR(info: cardInfo, snapshot: snapshot, signatures: [])
        
        let cardId = crypto
            .computeSHA256(for: snapshot)
            .hexEncodedString()
        
        if let privateKey = params.privateKey {
            csr.sign(crypto: crypto, params: SignParams(signerCardId: cardId, signerPrivateKey: privateKey, signerType: .self))
        }
        
        return csr
    }
}
