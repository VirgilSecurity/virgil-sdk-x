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
        var s = self.base64EncodedString()
        s = String(describing: s.split(separator: "=").first)
        s = s.replacingOccurrences(of: "+", with: "-")
        s = s.replacingOccurrences(of: "/", with: "_")
        return s
    }
    
    init(base64UrlEncoded: String) throws {
        var s = base64UrlEncoded
        s = s.replacingOccurrences(of: "-", with: "+")
        s = s.replacingOccurrences(of: "_", with: "/")
        switch s.count % 4 {
        case 0:
            break
        case 2:
            s += "=="
        case 3:
            s += "="
        default:
            Log.error("Illegal base64url string")
            // FIXME
            throw NSError()
        }
        
        guard let result = Data(base64Encoded: s) else {
            throw NSError()
        }
        self = result
    }
}
