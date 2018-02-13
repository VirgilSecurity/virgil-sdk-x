//
//  ModelSigner.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSModelSigner) public final class ModelSigner: NSObject {
    @objc public static let selfSignerIdentifier = "self"
    
    @objc public let crypto: CardCrypto

    @objc public init(crypto: CardCrypto) {
        self.crypto = crypto

        super.init()
    }

    @objc public func sign(model: RawSignedModel, signer: String, privateKey: PrivateKey,
                           additionalData: Data? = nil) throws {
        let combinedSnapshot = model.contentSnapshot + (additionalData ?? Data())
        let signature = try crypto.generateSignature(of: combinedSnapshot, using: privateKey)

        let rawSignature = RawSignature(signer: signer, signature: signature.base64EncodedString(),
                                        snapshot: additionalData?.base64EncodedString())

        try model.addSignature(rawSignature)
    }

    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey, additionalData: Data? = nil) throws {
        try self.sign(model: model, signer: ModelSigner.selfSignerIdentifier, privateKey: privateKey, additionalData: additionalData)
    }

    @objc public func sign(model: RawSignedModel, signer: String, privateKey: PrivateKey,
                           extraFields: [String: String]? = nil) throws {
        let additionalData: Data?
        if let extraFields = extraFields {
            additionalData = try? JSONSerialization.data(withJSONObject: extraFields, options: [])
        }
        else {
            additionalData = nil
        }

        try self.sign(model: model, signer: signer, privateKey: privateKey, additionalData: additionalData)
    }

    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey,
                               extraFields: [String: String]? = nil) throws {
        let additionalData: Data?
        if let extraFields = extraFields {
            additionalData = try? JSONSerialization.data(withJSONObject: extraFields, options: [])
        }
        else {
            additionalData = nil
        }

        try self.selfSign(model: model, privateKey: privateKey, additionalData: additionalData)
    }
}
