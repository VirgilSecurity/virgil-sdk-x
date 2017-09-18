//
//  SignerInfo.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSSignerInfo) public class SignerInfo: NSObject {
    public let cardId: String
    public let publicKey: Data
    
    public init(cardId: String, publicKey: Data) {
        self.cardId = cardId
        self.publicKey = publicKey
    }
}
