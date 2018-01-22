//
//  VirgilAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCallbackJwtProvider) public class CallbackJwtProvider: NSObject, AccessTokenProvider {
    @objc private(set) var token: Jwt?
    @objc private(set) var getTokenCallback: ()->(String)
    
    @objc public init(getTokenCallback: @escaping ()->(String)) {
        self.getTokenCallback = getTokenCallback
        
        super.init()
    }
    
    @objc public func getToken(forceReload: Bool) throws -> AccessToken {
        return try self.getVirgilToken(forceReload: forceReload)
    }
    
    @objc public func getVirgilToken(forceReload: Bool) throws -> Jwt {
        if forceReload || self.token == nil || self.token!.isExpired() {
            guard let jwt = Jwt(jwtToken: getTokenCallback()) else {
                throw NSError()
            }
            self.token = jwt
        }
        
        return self.token!
    }
    
    @objc public func setCallback(_ callback: @escaping ()->(String)) {
        self.getTokenCallback = callback
    }
}
