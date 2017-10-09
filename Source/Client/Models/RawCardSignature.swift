//
//  CardSignature.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCardSignature) public final class CardSignature: NSObject, Deserializable, Serializable {
    @objc public let signerId: String
    @objc public let signerType: SignerType
    @objc public let signature: Data
    @objc public let extraData: Data
    
    private enum Keys: String {
        case signerId = "signer_id"
        case signerType = "signer_type"
        case signature = "signature"
        case extraContent = "extra_content"
    }
    
    init(signerId: String, signerType: SignerType, signature: Data, extraData: Data) {
        self.signerId = signerId
        self.signerType = signerType
        self.signature = signature
        self.extraData = extraData
        
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
            let extraDataStr = candidate[Keys.extraContent.rawValue] as? String,
            let extraData = Data(base64Encoded: extraDataStr),
            let signature = Data(base64Encoded: signatureStr) else {
                return nil
        }
        
        self.init(signerId: signerId, signerType: signerType, signature: signature, extraData: extraData)
    }
    
    public func serialize() -> Any {
        return [
            Keys.signerId.rawValue: self.signerId,
            Keys.signerType.rawValue: self.signerType.toString(),
            Keys.signature.rawValue: self.signature.base64EncodedString(),
            Keys.extraContent.rawValue: self.extraData.base64EncodedString()
        ]
    }
}
