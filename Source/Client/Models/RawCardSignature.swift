//
//  RawSignature.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawCardSignature) public class RawCardSignature: NSObject, Deserializable {
    public let signerId: String
    public let signerType: String
    public let snapshot: Data
    public let signature: Data
    
    public required init?(dict: Any) {
        guard let candidate = dict as? [String : Any] else {
            return nil
        }
        
        guard let signerId = candidate["signer_id"] as? String,
            let signerType = candidate["signer_type"] as? String,
            let snapshotStr = candidate["snapshot_str"] as? String,
            let snapshot = Data(base64Encoded: snapshotStr),
            let signatureStr = candidate["signature"] as? String,
            let signature = Data(base64Encoded: signatureStr) else {
                return nil
        }
        
        self.signerId = signerId
        self.signerType = signerType
        self.snapshot = snapshot
        self.signature = signature
        
        super.init()
    }
}
