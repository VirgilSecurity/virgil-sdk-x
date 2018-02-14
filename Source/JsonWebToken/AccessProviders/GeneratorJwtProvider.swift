//
//  JwtGeneratorAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Implementation of AccessTokenProvider which provides generated JWTs
@objc(VSSGeneratorJwtProvider) public class GeneratorJwtProvider: NSObject, AccessTokenProvider {
    /// JwtGeneretor for generating new tokens
    @objc public let jwtGenerator: JwtGenerator
    /// Identity is used for generating token if tokenContext do not have it
    @objc public let defaultIdentity: String
    /// Dictionary with additional data to be inserted into generated token
    @objc public let additionalData: [String: String]?

    /// Initializer
    ///
    /// - Parameters:
    ///   - jwtGenerator: `JwtGeneretor` instance for generating new tokens
    ///   - defaultIdentity: identity is used for generating token if tokenContext do not have it
    ///   - additionalData: dictionary with additional data to be inserted into generated token
    @objc public init(jwtGenerator: JwtGenerator, defaultIdentity: String, additionalData: [String: String]? = nil) {
        self.defaultIdentity = defaultIdentity
        self.additionalData = additionalData
        self.jwtGenerator = jwtGenerator

        super.init()
    }

    /// Provides generated new JWT
    ///
    /// - Parameters:
    ///   - tokenContext: `TokenContext` instance with corresponding info
    ///   - completion: completion closure, called with generated JWT or corresponding error
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
