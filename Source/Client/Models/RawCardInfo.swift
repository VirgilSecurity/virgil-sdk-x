//
//  RawCardInfo.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawCardInfo) public class RawCardInfo: NSObject, Deserializable {
    public let identity: String
    public let publicKeyData: Data
    public let version: String
    
    required public init?(dict: Any) {
        guard let candidate = dict as? [AnyHashable : Any] else {
            return nil
        }
        
        guard let identity = candidate["identity"] as? String,
            let publicKeyStr = candidate["public_key"] as? String,
            let publicKeyData = Data(base64Encoded: publicKeyStr),
            let version = candidate["version"] as? String else {
                return nil
        }
        
        self.identity = identity
        self.publicKeyData = publicKeyData
        self.version = version
    }
}
