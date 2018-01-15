//
//  VirgilAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSVirgilAccessTokenProvider) public class VirgilAccessTokenProvider: NSObject, AccessTokenProvider {
    private let getTokenCallback: (()->(String))?
    
    @objc public init(getTokenCallback: (()->(String))?) {
        self.getTokenCallback = getTokenCallback
        
        super.init()
    }
    
    @objc public func getToken(forceReload: Bool) throws -> AccessToken {
        guard let getTokenCallback = self.getTokenCallback,
              let jwt = Jwt(jwtToken: getTokenCallback())else
        {
            throw NSError()
        }
        
        return jwt
    }
}
