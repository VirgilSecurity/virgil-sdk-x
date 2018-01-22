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
    private let apiPublicKey: PublicKey
    private let apiPublicKeyIdentifier: String
    private let accessTokenSigner: AccessTokenSigner
    
    @objc public init(apiPublicKey: PublicKey, apiPublicKeyIdentifier: String, accessTokenSigner: AccessTokenSigner) {
        self.apiPublicKey = apiPublicKey
        self.apiPublicKeyIdentifier = apiPublicKeyIdentifier
        self.accessTokenSigner = accessTokenSigner
    }
    
    @objc public func verifyToken(jwtToken: Jwt) throws {
        let signatureContent = jwtToken.signatureContent ?? Data() 
        
        try self.accessTokenSigner.verifyTokenSignature(signatureContent, of: try jwtToken.snapshotWithoutSignatures(), with: self.apiPublicKey)
    }
}
