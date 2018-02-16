//
//  JwtVerifier.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class responsible for verification of JWTs
@objc(VSSJwtVerifier) public class JwtVerifier: NSObject {
    /// Public Key which should be used to verify signatures
    @objc public let apiPublicKey: PublicKey
    /// Identifier of public key which should be used to verify signatures
    @objc public let apiPublicKeyIdentifier: String
    /// AccessTokenSigner implementation for verifying signatures
    @objc public let accessTokenSigner: AccessTokenSigner

    /// Initializer
    ///
    /// - Parameters:
    ///   - apiPublicKey: Public Key which should be used to verify signatures
    ///   - apiPublicKeyIdentifier: identifier of public key which should be used to verify signatures
    ///   - accessTokenSigner: AccessTokenSigner implementation for verifying signatures
    @objc public init(apiPublicKey: PublicKey, apiPublicKeyIdentifier: String, accessTokenSigner: AccessTokenSigner) {
        self.apiPublicKey = apiPublicKey
        self.apiPublicKeyIdentifier = apiPublicKeyIdentifier
        self.accessTokenSigner = accessTokenSigner
    }

    /// Verifies Jwt signature
    ///
    /// - Parameter token: Jwt to be verified
    /// - Returns: true if token verified, false otherwise
    @objc public func verify(token: Jwt) -> Bool {
        do {
            let data = try token.dataToSign()
            let signature = token.signatureContent.signature

            return self.accessTokenSigner.verifyTokenSignature(signature, of: data, with: self.apiPublicKey)
        }
        catch {
            return false
        }
    }
}
