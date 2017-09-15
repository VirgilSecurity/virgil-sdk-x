//
//  RawCardInfo.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawCardInfo) public class RawCardInfo: NSObject, Deserializable, Serializable {
    private enum Keys: String {
        case identity = "identity"
        case publicKeyData = "public_key"
        case version = "version"
    }
    
    public let identity: String
    public let publicKeyData: Data
    public let version: String
    
    init(identity: String, publicKeyData: Data, version: String) {
        self.identity = identity
        self.publicKeyData = publicKeyData
        self.version = version
        
        super.init()
    }
    
    required public convenience init?(dict: Any) {
        guard let candidate = dict as? [AnyHashable : Any] else {
            return nil
        }
        
        guard let identity = candidate[Keys.identity.rawValue] as? String,
            let publicKeyStr = candidate[Keys.publicKeyData.rawValue] as? String,
            let publicKeyData = Data(base64Encoded: publicKeyStr),
            let version = candidate[Keys.version.rawValue] as? String else {
                return nil
        }
        
        self.init(identity: identity, publicKeyData: publicKeyData, version: version)
    }
    
    public func serialize() -> Any {
        return [
            Keys.identity.rawValue: self.identity,
            Keys.publicKeyData.rawValue: self.publicKeyData.base64EncodedString(),
            Keys.version.rawValue: self.version
        ]
    }
}
