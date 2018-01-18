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
    private let crypto: CardCrypto
    
    @objc public init(crypto: CardCrypto) {
        self.crypto = crypto
        
        super.init()
    }
    
    @objc public func sign(model: RawSignedModel, type: SignerType, privateKey: PrivateKey, additionalData: Data = Data()) throws {
        let combinedSnapshot = model.contentSnapshot + additionalData
        let fingerprint = try self.crypto.generateSHA256(for: combinedSnapshot)
        let signature = try crypto.generateSignature(of: fingerprint, using: privateKey)
        
        let signerId = try crypto
            .generateSHA256(for: model.contentSnapshot)
            .hexEncodedString()
        
        let rawSignature = RawSignature(signerId: signerId, snapshot: additionalData.base64EncodedString(), signerType: type, signature: signature)
        
        model.signatures.append(rawSignature)
    }
    
    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey, additionalData: Data = Data()) throws {
        try self.sign(model: model, type: .self, privateKey: privateKey, additionalData: additionalData)
    }
}
