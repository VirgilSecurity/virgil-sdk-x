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
    @objc public let signer: String
    @objc public let signature: String
    @objc public let snapshot: String?

    /// Initializes a new `RawSignature` with the provided signer, signature and snapshot (optionally)
    ///
    /// - Parameters:
    ///   - signer: signer identifier
    ///   - signature: signature in base64 string
    ///   - snapshot: base64 string of additional data (optional)
    @objc public init(signer: String, signature: String, snapshot: String? = nil) {
        self.signer = signer
        self.signature = signature
        self.snapshot = snapshot

        super.init()
    }
}
