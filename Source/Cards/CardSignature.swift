//
//  CardSignature.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation


@objc(VSSCardSignature) public final class CardSignature: NSObject, Deserializable, Serializable {
    @objc public let signerId: String
    @objc public let signerType: SignerType
    @objc public let signature: Data
    @objc public let snapshot: String
    @objc public let extraFields: [String : Any]
    
    private enum Keys: String {
        case signerId = "signer_id"
        case signerType = "signer_type"
        case signature = "signature"
        case snapshot = "snapshot"
        case extraContent = "extra_content"
    }
    
    init(signerId: String, signerType: SignerType, signature: Data, snapshot: String, extraFields: [String: Any] = [:]) {
        self.signerId = signerId
        self.signerType = signerType
        self.signature = signature
        self.snapshot = snapshot
        self.extraFields = extraFields
        
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
            let extraFields = candidate[Keys.extraContent.rawValue] as? [String: Any],
            let signature = Data(base64Encoded: signatureStr) else {
                return nil
        }
        
        self.init(signerId: signerId, signerType: signerType, signature: signature, snapshot: snapshot, extraFields: extraFields)
    }
    
    public func serialize() -> Any {
        return [
            Keys.signerId.rawValue: self.signerId,
            Keys.signerType.rawValue: self.signerType.toString(),
            Keys.signature.rawValue: self.signature.base64EncodedString(),
            Keys.snapshot.rawValue: self.snapshot,
            Keys.extraContent.rawValue: self.extraFields
        ]
    }
}
