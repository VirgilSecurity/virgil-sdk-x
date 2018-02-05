//
//  RawSignature.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawSignature) public final class RawSignature: NSObject, Codable {
    @objc public let signer: String
    @objc public let signature: String
    @objc public let snapshot: String?
    
    @objc public init(signer: String, signature: String, snapshot: String? = nil) {
        self.signer = signer
        self.signature = signature
        self.snapshot = snapshot
        
        super.init()
    }
}
