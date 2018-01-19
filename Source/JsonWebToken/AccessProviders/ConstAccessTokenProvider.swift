//
//  ConstJwtAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSConstAccessTokenProvider) public class ConstAccessTokenProvider: NSObject, AccessTokenProvider {
    private let accessToken: AccessToken
    
    @objc public init(accessToken: AccessToken) {
        self.AccessToken = AccessToken
        
        super.init()
    }
    
    @objc public func getToken(forceReload: Bool) throws -> AccessToken {
        return jwtToken
    }
}
