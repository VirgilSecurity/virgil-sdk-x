//
//  VirgilAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Implementation of AccessTokenProvider which provides AccessToken using callback
@objc(VSSCallbackJwtProvider) public class CallbackJwtProvider: NSObject, AccessTokenProvider {
    /// Callback, which takes a TokenContext and completion handler, called with
    /// string representation of token or provided error
    @objc public let getTokenCallback: (TokenContext, (String?, Error?) -> ()) -> ()

    /// Declares error types and codes
    ///
    /// - callbackReturnedCorruptedJwt: importing `Jwt` instance from provided by callback string failed
    @objc public enum CallbackProviderError: Int, Error {
        case callbackReturnedCorruptedJwt = 1
    }

    /// Initializer
    ///
    /// - Parameter getTokenCallback: callback to cash, which takes a TokenContext and completion handler, called with
    /// string representation of token or provided error
    @objc public init(getTokenCallback: @escaping (TokenContext, (String?, Error?) -> ()) -> ()) {
        self.getTokenCallback = getTokenCallback

        super.init()
    }

    /// Provides access token using cashed callback
    ///
    /// - Parameters:
    ///   - tokenContext: `TokenContext` instance with corresponding info
    ///   - completion: completion closure, called with access token or corresponding error
    @objc public func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ()) {
        self.getTokenCallback(tokenContext) { tokenString, err in
            guard let tokenString = tokenString, err == nil else {
                completion(nil, err)
                return
            }
            guard let jwt = Jwt(stringRepresentation: tokenString) else {
                completion(nil, CallbackProviderError.callbackReturnedCorruptedJwt)
                return
            }

            completion(jwt, nil)
        }
    }
}
