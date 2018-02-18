//
//  JwtGeneratorAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Implementation of AccessTokenProvider which provides generated JWTs
@objc(VSSGeneratorJwtProvider) open class GeneratorJwtProvider: NSObject, AccessTokenProvider {
    /// JwtGeneretor for generating new tokens
    @objc public let jwtGenerator: JwtGenerator
    /// Identity that will be used for generating token if tokenContext do not have it (e.g. for read operations)
    /// WARNING: Do not create cards with defaultIdentity
    @objc public let defaultIdentity: String
    /// Additional data, that will be present in token
    @objc public let additionalData: [String: String]?

    /// Initializer
    ///
    /// - Parameters:
    ///   - jwtGenerator: `JwtGeneretor` instance for generating new tokens
    ///   - defaultIdentity: Identity that will be used for generating token
    ///                      if tokenContext do not have it (e.g. for read operations)
    ///                      WARNING: Do not create cards with defaultIdentity
    ///   - additionalData: Additional data, that will be present in token
    @objc public init(jwtGenerator: JwtGenerator, defaultIdentity: String, additionalData: [String: String]? = nil) {
        self.defaultIdentity = defaultIdentity
        self.additionalData = additionalData
        self.jwtGenerator = jwtGenerator

        super.init()
    }

    /// Provides new generated JWT
    ///
    /// - Parameters:
    ///   - tokenContext: `TokenContext`, provides context explaining why token is needed
    ///   - completion: completion closure, called with access token or corresponding error
    @objc public func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ()) {
        do {
            let token = try self.jwtGenerator.generateToken(identity: tokenContext.identity ?? self.defaultIdentity,
                                                            additionalData: self.additionalData)
            completion(token, nil)
        } catch {
            completion(nil, error)
        }
    }
}
