//
//  JwtVerifier.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSJwtVerifier) public class JwtVerifier: NSObject {
    @objc public let apiPublicKey: PublicKey
    @objc public let apiPublicKeyIdentifier: String
    @objc public let accessTokenSigner: AccessTokenSigner

    @objc public init(apiPublicKey: PublicKey, apiPublicKeyIdentifier: String, accessTokenSigner: AccessTokenSigner) {
        self.apiPublicKey = apiPublicKey
        self.apiPublicKeyIdentifier = apiPublicKeyIdentifier
        self.accessTokenSigner = accessTokenSigner
    }

    @objc public func verifyToken(jwtToken: Jwt) -> Bool {
        let signatureContent = jwtToken.signatureContent ?? Data()
        guard let data = try? jwtToken.snapshotWithoutSignatures() else {
            return false
        }

        return self.accessTokenSigner.verifyTokenSignature(signatureContent, of: data, with: self.apiPublicKey)
    }
}
