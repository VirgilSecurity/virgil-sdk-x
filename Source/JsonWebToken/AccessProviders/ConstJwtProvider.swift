//
//  ConstJwtAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSConstJwtProvider) public class ConstJwtProvider: NSObject, AccessTokenProvider {
    private let jwtToken: Jwt
    
    @objc public init(jwtToken: Jwt) {
        self.jwtToken = jwtToken
        
        super.init()
    }
    
    @objc public func getToken(forceReload: Bool) throws -> AccessToken {
        return jwtToken
    }
}
