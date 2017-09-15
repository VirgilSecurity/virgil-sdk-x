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
    public let identity: String
    public let publicKey: PublicKey
    public let privateKey: PrivateKey
    
    init(identity: String, publicKey: PublicKey, privateKey: PrivateKey) {
        self.identity = identity
        self.publicKey = publicKey
        self.privateKey = privateKey
        
        super.init()
    }
}
