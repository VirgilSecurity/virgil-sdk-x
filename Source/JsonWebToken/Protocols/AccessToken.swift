//
//  AccessToken.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// This protocol represents Access Token
@objc(VSSAccessToken) public protocol AccessToken {
    /// Provides string representation of token
    ///
    /// - Returns: string with token
    @objc func stringRepresentation() -> String

    /// Extracts identity
    ///
    /// - Returns: identity
    @objc func identity() -> String
}
