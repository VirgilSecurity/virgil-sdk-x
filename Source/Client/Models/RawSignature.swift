//
//  CardSignature.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawSignature) public final class RawSignature: NSObject, Deserializable, Serializable {
    @objc public let signerId: String
    @objc public let snapshot: String
    @objc public let signerType: SignerType
    @objc public let signature: Data
    
    private enum Keys: String {
        case signerId = "signer_id"
        case snapshot = "snapshot"
        case signerType = "signer_type"
        case signature = "signature"
    }
    
    init(signerId: String, snapshot: String, signerType: SignerType, signature: Data) {
        self.signerId = signerId
        self.snapshot = snapshot
        self.signerType = signerType
        self.signature = signature
        
        super.init()
    }
    
    convenience public init?(dict: Any) {
        guard let candidate = dict as? [String : Any] else {
            return nil
        }
        
        guard let signerId = candidate[Keys.signerId.rawValue] as? String,
            let signerTypeStr = candidate[Keys.signerType.rawValue] as? String,
            let signerType = SignerType(from: signerTypeStr),
            let signatureStr = candidate[Keys.signature.rawValue] as? String,
            let snapshot = candidate[Keys.snapshot.rawValue] as? String,
            let signature = Data(base64Encoded: signatureStr) else {
                return nil
        }
        
        self.init(signerId: signerId, snapshot: snapshot, signerType: signerType, signature: signature)
    }
    
    public func serialize() -> Any {
        return [
            Keys.signerId.rawValue: self.signerId,
            Keys.snapshot.rawValue: self.snapshot,
            Keys.signerType.rawValue: self.signerType.toString(),
            Keys.signature.rawValue: self.signature.base64EncodedString(),
        ]
    }
}
