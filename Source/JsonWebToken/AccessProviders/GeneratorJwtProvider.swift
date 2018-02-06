//
//  JwtGeneratorAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSGeneratorJwtProvider) public class GeneratorJwtProvider: NSObject, AccessTokenProvider {
    @objc public let jwtGenerator: JwtGenerator
    @objc public let defaultIdentity: String
    @objc public let additionalData: [String: String]?

    @objc public init(jwtGenerator: JwtGenerator, defaultIdentity: String, additionalData: [String: String]? = nil) {
        self.defaultIdentity = defaultIdentity
        self.additionalData = additionalData
        self.jwtGenerator = jwtGenerator

        super.init()
    }

    @objc public func getToken(with tokenContext: TokenContext) throws -> AccessToken {
        return try self.jwtGenerator.generateToken(identity: tokenContext.identity ?? self.defaultIdentity,
                                                   additionalData: self.additionalData)
    }
}
