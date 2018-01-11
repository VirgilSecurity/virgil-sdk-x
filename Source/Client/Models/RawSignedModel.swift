//
//  RawCard.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawSignedModel) public class RawSignedModel: NSObject, Deserializable, Serializable {
    @objc public let contentSnapshot: Data
    @objc public var signatures: [RawSignature]
    
    private enum Keys: String {
        case contentSnapshot = "content_snapshot"
        case signatures      = "signatures"
    }
    
    @objc public init(contentSnapshot: Data, signatures: [RawSignature]) {
        self.contentSnapshot = contentSnapshot
        self.signatures      = signatures
        
        super.init()
    }
    
    public required convenience init?(dict: Any) {
        guard let candidate = dict as? [String : AnyObject] else {
            return nil
        }
        
        guard let snapshotStr = candidate[Keys.contentSnapshot.rawValue] as? String,
            let snapshot = Data(base64Encoded: snapshotStr),
            let signaturesArray = candidate[Keys.signatures.rawValue] as? [[String : Any]] else {
                return nil
        }
        
        var signatures: [RawSignature] = []
        signatures.reserveCapacity(signaturesArray.count)
        for signatureDict in signaturesArray {
            guard let signature = RawSignature(dict: signatureDict) else {
                return nil
            }
            
            signatures.append(signature)
        }
        
        self.init(contentSnapshot: snapshot, signatures: signatures)
    }
    
    public func serialize() -> Any {
        return [
            Keys.contentSnapshot.rawValue: self.contentSnapshot.base64EncodedString(),
            Keys.signatures.rawValue: self.signatures.serialize()
        ]
    }
}
