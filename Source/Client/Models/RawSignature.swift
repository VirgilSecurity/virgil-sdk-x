//
//  RawSignature.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawSignature) public final class RawSignature: NSObject, Codable {
    @objc public let signerId:   String
    @objc public let signerType: String
    @objc public let snapshot:   String?
    @objc public let signature:  String
    
    private enum CodingKeys: String, CodingKey {
        case signerId   = "signer_id"
        case signerType = "signer_type"
        
        case snapshot  
        case signature
    }
    
   @objc public init(signerId: String, snapshot: String? = nil, signerType: String, signature: String) {
        self.signerId   = signerId
        self.snapshot   = snapshot
        self.signerType = signerType
        self.signature  = signature
        
        super.init()
    }
}
