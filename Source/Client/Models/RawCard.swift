//
//  RawCard.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawCard) public class RawCard: NSObject, Deserializable {
    public let contentSnapshot: Data
    public let signatures: [RawCardSignature]
    
    public init(contentSnapshot: Data, signatures: [RawCardSignature]) {
        self.contentSnapshot = contentSnapshot
        self.signatures = signatures
        
        super.init()
    }
    
    public required convenience init?(dict: Any) {
        guard let candidate = dict as? [String : AnyObject] else {
            return nil
        }
        
        guard let snapshotStr = candidate["content_snapshot"] as? String,
            let snapshot = Data(base64Encoded: snapshotStr),
            let signaturesArray = candidate["signatures"] as? [[String : Any]] else {
                return nil
        }
        
        var signatures: [RawCardSignature] = []
        signatures.reserveCapacity(signaturesArray.count)
        for signatureDict in signaturesArray {
            guard let signature = RawCardSignature(dict: signatureDict) else {
                return nil
            }
            
            signatures.append(signature)
        }
        
        self.init(contentSnapshot: snapshot, signatures: signatures)
    }
}
