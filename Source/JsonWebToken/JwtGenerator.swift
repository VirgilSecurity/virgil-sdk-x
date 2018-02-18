//
//  JwtGenerator.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class responsible for JWT generation
@objc(VSSJwtGenerator) open class JwtGenerator: NSObject {
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
    ///   - identity: Identity to generate with
    ///   - additionalData: Dictionary with additional data
    /// - Returns: Generated and signed `Jwt`
    /// - Throws: Rethrows from JwtHeaderContent, JwtBodyContent, Jwt, AccessTokenSigner
    @objc public func generateToken(identity: String, additionalData: [String: String]? = nil) throws -> Jwt {
        let jwtHeaderContent = try JwtHeaderContent(keyIdentifier: self.apiPublicKeyIdentifier)
        let jwtBodyContent = try JwtBodyContent(appId: self.appId, identity: identity,
                                                expiresAt: Date() + self.ttl, issuedAt: Date(),
                                                additionalData: additionalData)

        let data = try Jwt.dataToSign(headerContent: jwtHeaderContent, bodyContent: jwtBodyContent)

        let signature = try self.accessTokenSigner.generateTokenSignature(of: data, using: self.apiKey)
        
        return try Jwt(headerContent: jwtHeaderContent, bodyContent: jwtBodyContent, signatureContent: JwtSignatureContent(signature: signature))
    }
}
