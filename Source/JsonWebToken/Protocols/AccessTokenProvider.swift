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
    /// - Parameter tokenContext: `TokenContext` instance with corresponding info
    /// - Returns: access token
    /// - Throws: corresponding error
    @objc func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ())
}
