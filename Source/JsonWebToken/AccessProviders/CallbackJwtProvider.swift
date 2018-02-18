//
//  VirgilAccessTokenProvider.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Implementation of AccessTokenProvider which provides AccessToken using callback
@objc(VSSCallbackJwtProvider) open class CallbackJwtProvider: NSObject, AccessTokenProvider {
    /// Callback, which takes a TokenContext and completion handler
    /// Completion handler should be called with either JWT string, or Error
    @objc public let getTokenCallback: (TokenContext, (String?, Error?) -> ()) -> ()

    /// Initializer
    ///
    /// - Parameter getTokenCallback: Callback, which takes a TokenContext and completion handler
    ///                               Completion handler should be called with either JWT string, or Error
    @objc public init(getTokenCallback: @escaping (TokenContext, (String?, Error?) -> ()) -> ()) {
        self.getTokenCallback = getTokenCallback

        super.init()
    }

    /// Provides access token using callback
    ///
    /// - Parameters:
    ///   - tokenContext: `TokenContext` provides context explaining why token is needed
    ///   - completion: completion closure
    @objc public func getToken(with tokenContext: TokenContext, completion: @escaping (AccessToken?, Error?) -> ()) {
        self.getTokenCallback(tokenContext) { tokenString, err in
            guard let tokenString = tokenString, err == nil else {
                completion(nil, err)
                return
            }

            do {
                let jwt = try Jwt(stringRepresentation: tokenString)
                completion(jwt, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }
}
