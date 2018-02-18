//
//  Data+base64Url.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

// MARK: - Data extension for base64Url encoding and decoding
public extension Data {
    /// Encodes data in base64Url format
    ///
    /// - Returns: Base64Url-encoded string
    func base64UrlEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Initializer
    ///
    /// - Parameter base64UrlEncoded: base64UrlEncoded-encoded string
    init?(base64UrlEncoded: String) {
        let base64Encoded = base64UrlEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padLength = (4 - (base64Encoded.count % 4)) % 4
        let base64EncodedWithPadding = base64Encoded + String(repeating: "=", count: padLength)

        self.init(base64Encoded: base64EncodedWithPadding)
    }
}
