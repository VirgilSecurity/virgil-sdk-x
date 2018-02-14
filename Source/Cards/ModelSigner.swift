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

    @objc public let cardCrypto: CardCrypto

    @objc public init(cardCrypto: CardCrypto) {
        self.cardCrypto = cardCrypto

        super.init()
    }

    @objc public func sign(model: RawSignedModel, signer: String, privateKey: PrivateKey,
                           additionalData: Data? = nil) throws {
        let combinedSnapshot = model.contentSnapshot + (additionalData ?? Data())
        let signature = try cardCrypto.generateSignature(of: combinedSnapshot, using: privateKey)

        let rawSignature = RawSignature(signer: signer, signature: signature,
                                        snapshot: additionalData)

        try model.addSignature(rawSignature)
    }

    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey, additionalData: Data? = nil) throws {
        try self.sign(model: model, signer: ModelSigner.selfSignerIdentifier,
                      privateKey: privateKey, additionalData: additionalData)
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
