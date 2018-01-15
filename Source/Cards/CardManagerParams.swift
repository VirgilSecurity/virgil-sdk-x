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
    @objc public var accessTokenProvider: AccessTokenProvider
    @objc public var cardVerifier: CardVerifier?
    @objc public var apiUrl: URL
    @objc public var signCallback: ((RawSignedModel)->(RawSignedModel))?
    
    @objc public init(crypto: CardCrypto, accessTokenProvider: AccessTokenProvider, cardVerifier: CardVerifier?, signCallback: ((RawSignedModel)->(RawSignedModel))?) {
        self.crypto = crypto
        self.apiUrl = URL(string: "https://cards.virgilsecurity.com/v5/")!
        self.cardVerifier = cardVerifier
        self.accessTokenProvider = accessTokenProvider
        self.signCallback = signCallback
    }
}
