//
//  ConstJwtAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Implementation of AccessTokenProvider which provides constant AccessToken
@objc(VSSConstAccessTokenProvider) public class ConstAccessTokenProvider: NSObject, AccessTokenProvider {
    /// Cashed AccessToken
    @objc public let accessToken: AccessToken

    /// Initializer
    ///
    /// - Parameter accessToken: AccessToken provider will contain
    @objc public init(accessToken: AccessToken) {
        self.accessToken = accessToken

        super.init()
    }

    /// Provides cashed access token
    ///
    /// - Parameters:
    ///   - tokenContext: do not have any influance on result in this implementation
    ///   - completion: completion closure, called with cashed access token
    @objc public func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ()) {
        completion(self.accessToken, nil)
    }
}
