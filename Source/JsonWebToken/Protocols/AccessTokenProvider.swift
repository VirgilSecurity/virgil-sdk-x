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
    /// - Parameter forceReload: true will invalidate cached token
    /// - Returns: access token
    @objc func getToken(tokenContext: TokenContext) throws -> AccessToken
}
