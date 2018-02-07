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
    @objc func getToken(with tokenContext: TokenContext) throws -> AccessToken
}
