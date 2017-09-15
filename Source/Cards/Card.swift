//
//  Card.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCard) public class Card: NSObject {
    public let identifier: String
    public let identity: String
    public let fingerprint: Data
    public let publicKey: PublicKey
    public let version: String
    
    private init(identifier: String, identity: String, fingerprint: Data, publicKey: PublicKey, version: String) {
        self.identifier = identifier
        self.identity = identity
        self.fingerprint = fingerprint
        self.publicKey = publicKey
        self.version = version
        
        super.init()
    }
//    
//    public class func parse(crypto: Crypto, rawCard: RawCard) -> Card {
//        
//    }
}
