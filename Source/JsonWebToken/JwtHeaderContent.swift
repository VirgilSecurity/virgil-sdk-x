//
//  JwtHeaderContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtHeaderContent) public class JwtHeaderContent: NSObject, Serializable, Deserializable {
    let algorithm: String
    let type: String
    let contentType: String
    let keyIdentifier: String
    
    private enum Keys: String {
        case algorithm     = "alg"
        case type          = "typ"
        case contentType   = "cty"
        case keyIdentifier = "kid"
    }
    
    @objc public init(algorithm: String = "VEDS512", type: String = "JWT", contentType: String = "virgil-jwt;v1", keyIdentifier: String) {
        self.algorithm     = algorithm
        self.type          = type
        self.contentType   = contentType
        self.keyIdentifier = keyIdentifier
        
        super.init()
    }
    
    public required convenience init?(dict: Any) {
        guard let candidate = dict as? [String : AnyObject] else {
            return nil
        }
        
        guard let algorithm     = candidate[Keys.algorithm.rawValue]     as? String,
              let type          = candidate[Keys.type.rawValue]          as? String,
              let contentType   = candidate[Keys.contentType.rawValue]   as? String,
              let keyIdentifier = candidate[Keys.keyIdentifier.rawValue] as? String else
        {
            return nil
        }
        
        self.init(algorithm: algorithm, type: type, contentType: contentType, keyIdentifier: keyIdentifier)
    }
    
    public func serialize() -> Any {
        return [
            Keys.algorithm.rawValue:     self.algorithm,
            Keys.type.rawValue:          self.type,
            Keys.contentType.rawValue:   self.contentType,
            Keys.keyIdentifier.rawValue: self.keyIdentifier
        ]
    }
}
