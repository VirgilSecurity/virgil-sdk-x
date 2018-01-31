//
//  ModelSigner.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSModelSigner) public class ModelSigner: NSObject {
    @objc public let crypto: CardCrypto
    
    @objc public init(crypto: CardCrypto) {
        self.crypto = crypto
        
        super.init()
    }
    
    @objc public func sign(model: RawSignedModel, id: String, type: SignerType, privateKey: PrivateKey, additionalData: Data? = nil) throws {
        let combinedSnapshot = model.contentSnapshot + (additionalData ?? Data())
        let fingerprint = try self.crypto.generateSHA256(for: combinedSnapshot)
        let signature = try crypto.generateSignature(of: fingerprint, using: privateKey)
        
        let rawSignature = RawSignature(signerId: id, snapshot: additionalData?.base64EncodedString(), signerType: type, signature: signature)
        
        try model.addSignature(rawSignature)
    }
    
    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey, additionalData: Data? = nil) throws {
        let combinedSnapshot = model.contentSnapshot + (additionalData ?? Data())
        let fingerprint = try self.crypto.generateSHA256(for: combinedSnapshot)
        let signerId = fingerprint.hexEncodedString()
        
        let signature = try crypto.generateSignature(of: fingerprint, using: privateKey)
        let rawSignature = RawSignature(signerId: signerId, snapshot: additionalData?.base64EncodedString(), signerType: .self, signature: signature)
        
        try model.addSignature(rawSignature)
    }
}
