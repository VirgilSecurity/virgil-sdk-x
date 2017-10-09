//
//  SignParams.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSSignParams) public class SignParams: NSObject {
    @objc public let signerCardId: String
    
    @objc public let signerPrivateKey: PrivateKey
    
    @objc public let signerType: SignerType
    
    @objc public let extraFields: [String : String]?
    
    init(signerCardId: String, signerPrivateKey: PrivateKey, signerType: SignerType, extraFields: [String : String]? = nil) {
        self.signerCardId = signerCardId
        self.signerPrivateKey = signerPrivateKey
        self.signerType = signerType
        self.extraFields = extraFields
    }
}
