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
    public var crypto: Crypto
    public var validator: CardValidator
    public var apiToken: String?
    public var apiUrl: URL
    
    public init(crypto: Crypto, validator: CardValidator) {
        self.crypto = crypto
        self.apiUrl = URL(string: "")!
        self.validator = validator
    }
}
