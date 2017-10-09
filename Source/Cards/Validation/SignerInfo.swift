//
//  SignerInfo.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSSignerInfo) public class SignerInfo: NSObject {
    @objc public let cardId: String
    @objc public let publicKey: Data
    
    @objc public init(cardId: String, publicKey: Data) {
        self.cardId = cardId
        self.publicKey = publicKey
    }
}
