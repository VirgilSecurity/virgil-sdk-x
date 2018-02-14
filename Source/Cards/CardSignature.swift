//
//  CardSignature.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing Virgil Card Signature
@objc(VSSCardSignature) public final class CardSignature: NSObject {
    /// Identifier of signer
    /// - Important: Must be unique. Reserved values:
    ///   - Self signatures: "self"
    ///   - Virgil Service signatures: "virgil"
    @objc public let signer: String
    /// Signature data
    @objc public let signature: Data
    /// Additional data
    @objc public let snapshot: Data?
    /// Dictionary with additional data
    @objc public let extraFields: [String: String]?

    /// Initializer
    ///
    /// - Parameters:
    ///   - signer: identifier of signer
    ///   - signature: signature data
    ///   - snapshot: additional data
    ///   - extraFields: dictionary with additional data
    @objc public init(signer: String, signature: Data, snapshot: Data?, extraFields: [String: String]? = nil) {
        self.signer = signer
        self.signature = signature
        self.snapshot = snapshot
        self.extraFields = extraFields

        super.init()
    }
}
