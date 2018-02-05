//
//  Data+base64Url.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

public extension Data {
    func base64UrlEncoded() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    init?(base64UrlEncoded: String) {
        let base64Encoded = base64UrlEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padLength = (4 - (base64Encoded.count % 4)) % 4
        let base64EncodedWithPadding = base64Encoded + String(repeating: "=", count: padLength)
        
        self.init(base64Encoded: base64EncodedWithPadding)
    }
}
