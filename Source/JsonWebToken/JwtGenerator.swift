//
//  JwtGenerator.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class responsible for generation of JWTs
@objc(VSSJwtGenerator) public class JwtGenerator: NSObject {
    /// Api Private Key for signing generated tokens
    /// - Note: Can be taken [here](https://dashboard.virgilsecurity.com/api-keys)
    @objc public let apiKey: PrivateKey
    /// Public Key identifier of Api Key
    /// - Note: Can be taken [here](https://dashboard.virgilsecurity.com/api-keys)
    @objc public let apiPublicKeyIdentifier: String
    /// Implementation of AccessTokenSigner for signing generated tokens
    @objc public let accessTokenSigner: AccessTokenSigner
    /// Application Id
    /// - Note: Can be taken [here](https://dashboard.virgilsecurity.com)
    @objc public let appId: String
    /// Lifetime of generated tokens
    @objc public let ttl: TimeInterval

    /// Declares error types and codes
    ///
    /// - generationFailed: generation of new token failed
    @objc(VSSJwtGeneratorError) public enum JwtGeneratorError: Int, Error {
        case generationFailed = 1
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - apiKey: Api Private Key for signing generated tokens
    ///   - apiPublicKeyIdentifier: Public Key identifier of Api Key
    ///   - accessTokenSigner: implementation of AccessTokenSigner for signing generated tokens
    ///   - appId: Application Id
    ///   - ttl: Lifetime of generated tokens
    @objc public init(apiKey: PrivateKey, apiPublicKeyIdentifier: String,
                      accessTokenSigner: AccessTokenSigner, appId: String, ttl: TimeInterval) {
        self.apiKey = apiKey
        self.apiPublicKeyIdentifier = apiPublicKeyIdentifier
        self.accessTokenSigner = accessTokenSigner
        self.appId = appId
        self.ttl = ttl

        super.init()
    }

    /// Generates new JWT
    ///
    /// - Parameters:
    ///   - identity: identity to generate with
    ///   - additionalData: dictionary with additional data
    /// - Returns: generated and signed `Jwt`
    /// - Throws: corresponding error if generation fails
    @objc public func generateToken(identity: String, additionalData: [String: String]? = nil) throws -> Jwt {
        let jwtHeaderContent = JwtHeaderContent(keyIdentifier: self.apiPublicKeyIdentifier)
        let jwtBodyContent = JwtBodyContent(appId: self.appId, identity: identity,
                                            expiresAt: Date() + self.ttl, issuedAt: Date(),
                                            additionalData: additionalData)

        guard let jwt = Jwt(headerContent: jwtHeaderContent, bodyContent: jwtBodyContent),
              let snapshot = jwt.unsignedString.data(using: .utf8) else {
            throw JwtGeneratorError.generationFailed
        }

        let signatureContent = try self.accessTokenSigner.generateTokenSignature(of: snapshot, using: self.apiKey)
        try jwt.setSignatureContent(signatureContent)

        return jwt
    }
}
