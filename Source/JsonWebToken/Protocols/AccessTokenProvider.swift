//
//  AccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// This protocol is responsible for providing AccessToken
@objc(VSSAccessTokenProvider) public protocol AccessTokenProvider {
    /// Provides access token
    ///
    /// - Parameters:
    ///   - tokenContext: `TokenContext` instance with corresponding info
    ///   - completion: completion closure, called with access token or corresponding error
    @objc func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ())
}
