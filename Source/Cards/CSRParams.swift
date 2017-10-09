//
//  CSRParams.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCSRParams) public class CSRParams: NSObject {
    @objc public let identity: String
    @objc public let publicKey: PublicKey
    @objc public let privateKey: PrivateKey?
    
    @objc public init(identity: String, publicKey: PublicKey, privateKey: PrivateKey?) {
        self.identity = identity
        self.publicKey = publicKey
        self.privateKey = privateKey
        
        super.init()
    }
}
