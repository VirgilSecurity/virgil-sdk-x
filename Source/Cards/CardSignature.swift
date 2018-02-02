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
    @objc public let snapshot: Data
    @objc public let extraFields: [String : String]?
    
    init(signerId: String, signerType: String, signature: Data, snapshot: Data?, extraFields: [String: String]? = nil) {
        self.signerId = signerId
        self.signerType = signerType
        self.signature = signature
        self.snapshot = snapshot ?? Data()
        self.extraFields = extraFields
        
        super.init()
    }
}
