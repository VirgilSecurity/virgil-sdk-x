//
//  CardManagerParams.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

// FIXME
@objc(VSSCardManagerParams) public class CardManagerParams: NSObject {
    public var crypto: Crypto
//    public var validator
    public var apiToken: String?
    public var apiUrl: URL
    
    public init(crypto: Crypto) {
        self.crypto = crypto
        self.apiUrl = URL(string: "")!
    }
}
