//
//  ModelSigner.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class responsible for signing RawSignerModel
@objc(VSSModelSigner) public final class ModelSigner: NSObject {
    /// Signer identifier for self signatures
    @objc public static let selfSignerIdentifier = "self"
    /// CardCrypto implementation instance for generating signatures
    @objc public let cardCrypto: CardCrypto

    /// Initializer
    ///
    /// - Parameter cardCrypto: CardCrypto implementation instance for generating signatures
    @objc public init(cardCrypto: CardCrypto) {
        self.cardCrypto = cardCrypto

        super.init()
    }

    /// Adds signature to given RawSignedModel with provided signer, privateKey and additionalData
    ///
    /// - Parameters:
    ///   - model: RawSignedModel to sign
    ///   - signer: identifier of signer
    ///   - privateKey: PrivateKey to sign with
    ///   - additionalData: additionalData to sign with model
    /// - Throws: corresponding error id signature generation fails
    @objc public func sign(model: RawSignedModel, signer: String, privateKey: PrivateKey,
                           additionalData: Data? = nil) throws {
        let combinedSnapshot = model.contentSnapshot + (additionalData ?? Data())
        let signature = try cardCrypto.generateSignature(of: combinedSnapshot, using: privateKey)

        let rawSignature = RawSignature(signer: signer, signature: signature,
                                        snapshot: additionalData)

        try model.addSignature(rawSignature)
    }

    /// Adds owner's signature to given RawSignedModel using provided PrivateKey
    ///
    /// - Parameters:
    ///   - model: RawSignedModel to sign
    ///   - privateKey: PrivateKey to sign with
    ///   - additionalData: additionalData to sign with model
    /// - Throws: corresponding error id signature generation fails
    @objc public func selfSign(model: RawSignedModel, privateKey: PrivateKey, additionalData: Data? = nil) throws {
        try self.sign(model: model, signer: ModelSigner.selfSignerIdentifier,
                      privateKey: privateKey, additionalData: additionalData)
    }

    /// Adds signature to given RawSignedModel with provided signer, privateKey and additionalData
    ///
    /// - Parameters:
    ///   - model: RawSignedModel to sign
    ///   - signer: identifier of signer
    ///   - privateKey: PrivateKey to sign with
    ///   - extraFields: Dictionary with extra data to sign with model
    /// - Throws: corresponding error id signature generation fails
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

    /// Adds owner's signature to given RawSignedModel using provided PrivateKey
    ///
    /// - Parameters:
    ///   - model: RawSignedModel to sign
    ///   - privateKey: PrivateKey to sign with
    ///   - extraFields: Dictionary with extra data to sign with model
    /// - Throws: corresponding error id signature generation fails
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
