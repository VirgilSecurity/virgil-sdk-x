//
//  JwtGeneratorAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSGeneratorJwtProvider) public class GeneratorJwtProvider: NSObject, AccessTokenProvider {
    private let jwtGenerator: JwtGenerator
    private let defaultIdentity: String
    private let additionalData: [String : String]?
    
    @objc public init(jwtGenerator: JwtGenerator, defaultIdentity: String, additionalData: [String : String]? = nil) {
        self.defaultIdentity = defaultIdentity
        self.additionalData = additionalData
        self.jwtGenerator = jwtGenerator
        
        super.init()
    }
    
    @objc public func getToken(tokenContext: TokenContext) throws -> AccessToken {
        return try self.jwtGenerator.generateToken(identity: self.defaultIdentity, additionalData: self.additionalData)
    }
}
