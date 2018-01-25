//
//  CardSignature.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCardSignature) public final class CardSignature: NSObject {
    @objc public let signerId: String
    @objc public let signerType: String
    @objc public let signature: Data
    @objc public let snapshot: String
    @objc public let extraFields: [String : String]
    
    init(signerId: String, signerType: SignerType, signature: Data, snapshot: String, extraFields: [String: String] = [:]) {
        self.signerId = signerId
        self.signerType = signerType.toString()
        self.signature = signature
        self.snapshot = snapshot
        self.extraFields = extraFields
        
        super.init()
    }
}
