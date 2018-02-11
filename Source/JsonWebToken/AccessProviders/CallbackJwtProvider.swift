//
//  VirgilAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCallbackJwtProvider) public class CallbackJwtProvider: NSObject, AccessTokenProvider {
    @objc public private(set) var token: Jwt?
    @objc public let getTokenCallback: ((String?, Error?) -> ()) -> ()

    @objc public enum CallbackProviderError: Int, Error {
        case callbackReturnedCorruptedJwt = 1
    }

    @objc public init(getTokenCallback: @escaping ((String?, Error?) -> ()) -> ()) {
        self.getTokenCallback = getTokenCallback

        super.init()
    }

    @objc public func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ()) {
        if tokenContext.forceReload || self.token == nil || self.token!.isExpired() {
            self.getTokenCallback { tokenString, err in
                guard let tokenString = tokenString, err == nil else {
                    completion(nil, err)
                    return
                }
                guard let jwt = Jwt(stringRepresentation: tokenString) else {
                    completion(nil, CallbackProviderError.callbackReturnedCorruptedJwt)
                    return
                }
                self.token = jwt

                completion(jwt, nil)
            }
        }
        completion(self.token, nil)
    }
}
