//
//  Whitelist.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Declares error types and codes
///
/// - duplicateSigner: tried to add verifier credentials from same signer
@objc(VSSWhitelistError) public enum WhitelistError: Int, Error {
    case duplicateSigner = 1
}

/// Class representing collection of verifiers
/// - Important: Card should contain signature from AT LEAST one verifier from collection of verifiers
@objc(VSSWhitelist) public class Whitelist: NSObject {
    /// Array of verifier credentials
    /// - Note: Card must be signed by AT LEAST one of them
    @objc public let verifiersCredentials: [VerifierCredentials]

    /// Initializer
    ///
    /// - Parameter verifiersCredentials: array of verifier credentials
    /// - Throws: corresponding `WhitelistError`
    @objc public init(verifiersCredentials: [VerifierCredentials]) throws {
        self.verifiersCredentials = verifiersCredentials

        let signers = self.verifiersCredentials.map { $0.signer }

        for signer in signers {
            guard signers.filter({ $0 == signer }).count < 2 else {
                throw WhitelistError.duplicateSigner
            }
        }

        super.init()
    }
}
