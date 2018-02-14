//
//  VerifierCredentials.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing verifier credentials
@objc(VSSVerifierCredentials) public class VerifierCredentials: NSObject {
    /// Identifier of signer
    /// - Important: Must be unique. Reserved values:
    ///   - Self verifier: "self"
    ///   - Virgil Service verifier: "virgil"
    @objc public let signer: String
    /// Exported Public Key to verify with
    @objc public let publicKey: Data

    /// Initializer
    ///
    /// - Parameters:
    ///   - signer: identifier of signer
    ///   - publicKey: exported Public Key to verify with
    @objc public init(signer: String, publicKey: Data) {
        self.signer = signer
        self.publicKey = publicKey

        super.init()
    }
}
