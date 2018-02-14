//
//  JwtGenerator.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSJwtGenerator) public class JwtGenerator: NSObject {
    @objc public let apiKey: PrivateKey
    @objc public let apiPublicKeyIdentifier: String
    @objc public let accessTokenSigner: AccessTokenSigner
    @objc public let appId: String
    @objc public let ttl: TimeInterval

    @objc(VSSJwtGeneratorError) public enum JwtGeneratorError: Int, Error {
        case generationFailed = 1
    }

    @objc public init(apiKey: PrivateKey, apiPublicKeyIdentifier: String,
                      accessTokenSigner: AccessTokenSigner, appId: String, ttl: TimeInterval) {
        self.apiKey = apiKey
        self.apiPublicKeyIdentifier = apiPublicKeyIdentifier
        self.accessTokenSigner = accessTokenSigner
        self.appId = appId
        self.ttl = ttl

        super.init()
    }

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
