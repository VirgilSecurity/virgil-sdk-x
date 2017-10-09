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
        case identity      = "identity"
        case publicKeyData = "public_key"
        case meta          = "meta"
        case version       = "version"
        case createdAt     = "created_at"
    }
    
    @objc public let identity: String
    @objc public let publicKeyData: Data
    @objc public let version: String
    @objc public let createdAt: Date
    
    init(identity: String, publicKeyData: Data, version: String, createdAt: Date) {
        self.identity = identity
        self.publicKeyData = publicKeyData
        self.version = version
        self.createdAt = createdAt
        
        super.init()
    }
    
    required public convenience init?(dict: Any) {
        guard let candidate = dict as? [AnyHashable : Any] else {
            return nil
        }
        
        guard let identity = candidate[Keys.identity.rawValue] as? String,
            let publicKeyStr = candidate[Keys.publicKeyData.rawValue] as? String,
            let publicKeyData = Data(base64Encoded: publicKeyStr),
            let meta = candidate[Keys.meta.rawValue] as? [AnyHashable : Any],
            let version = meta[Keys.version.rawValue] as? String,
            let createdAt = meta[Keys.createdAt.rawValue] as? Double else {
                return nil
        }
        
        self.init(identity: identity, publicKeyData: publicKeyData, version: version, createdAt: Date(timeIntervalSince1970: createdAt))
    }
    
    public func serialize() -> Any {
        return [
            Keys.identity.rawValue: self.identity,
            Keys.publicKeyData.rawValue: self.publicKeyData.base64EncodedString(),
            Keys.meta.rawValue: [
                Keys.version.rawValue: self.version,
                Keys.createdAt.rawValue: Int(self.createdAt.timeIntervalSince1970)
            ]
        ]
    }
}
