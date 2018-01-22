//
//  VerifierCredentials.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSVerifierCredentials) public class VerifierCredentials: NSObject {
    @objc public let id: String
    @objc public let publicKey: Data
    
    @objc public init(id: String, publicKey: Data) {
        self.id = id
        self.publicKey = publicKey
    }
}
