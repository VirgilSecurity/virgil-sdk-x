//
//  CardManagerParams.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCardManagerParams) public class CardManagerParams: NSObject {
    @objc public var crypto: CardCrypto
    @objc public var validator: CardVerifier?
    @objc public var apiToken: String?
    @objc public var apiUrl: URL
    
    @objc public init(crypto: CardCrypto, validator: CardVerifier?) {
        self.crypto = crypto
        self.apiUrl = URL(string: "https://cards.virgilsecurity.com/v5/")!
        self.validator = validator
    }
}
