//
//  RawSignature.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents signature for `RawSignedModel`
@objc(VSSRawSignature) public final class RawSignature: NSObject, Codable {
    /// Identifier of signer
    /// - Important: Must be unique. Reserved values:
    ///   - Self signatures: "self"
    ///   - Virgil Service signatures: "virgil"
    @objc public let signer: String
    /// Signature data
    @objc public let signature: Data
    /// Additional data
    @objc public let snapshot: Data?

    /// Initializes a new `RawSignature` with the provided signer, signature and snapshot (optionally)
    ///
    /// - Parameters:
    ///   - signer: identifier of signer
    ///   - signature: signature data
    ///   - snapshot: additional data
    @objc public init(signer: String, signature: Data, snapshot: Data? = nil) {
        self.signer = signer
        self.signature = signature
        self.snapshot = snapshot

        super.init()
    }
}
