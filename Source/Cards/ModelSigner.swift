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

    @objc public func sign(model: RawSignedModel, signer: String, privateKey: PrivateKey,
                           additionalData: Data? = nil) throws {
        let combinedSnapshot = model.contentSnapshot + (additionalData ?? Data())
        let fingerprint = try self.crypto.generateSHA256(for: combinedSnapshot)
        let signature = try crypto.generateSignature(of: fingerprint, using: privateKey)

        let rawSignature = RawSignature(signer: signer, signature: signature.base64EncodedString(),
                                        snapshot: additionalData?.base64EncodedString())

        try model.addSignature(rawSignature)
    }

    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey, additionalData: Data? = nil) throws {
        try self.sign(model: model, signer: "self", privateKey: privateKey, additionalData: additionalData)
    }

    @objc public func sign(model: RawSignedModel, signer: String, privateKey: PrivateKey,
                           extraFields: [String: String]? = nil) throws {
        let additionalData = try? JSONSerialization.data(withJSONObject: extraFields as Any, options: [])

        try self.sign(model: model, signer: signer, privateKey: privateKey, additionalData: additionalData)
    }

    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey,
                               extraFields: [String: String]? = nil) throws {
        let additionalData = try? JSONSerialization.data(withJSONObject: extraFields as Any, options: [])

        try self.sign(model: model, signer: "self", privateKey: privateKey, additionalData: additionalData)
    }
}
