//
//  CardManagerParams.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCardManagerParams) public final class CardManagerParams: NSObject {
    @objc public let cardCrypto: CardCrypto
    @objc public let accessTokenProvider: AccessTokenProvider
    @objc public let cardVerifier: CardVerifier
    @objc public var modelSigner: ModelSigner
    @objc public var cardClient: CardClient
    @objc public var signCallback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)?
    @objc public var retryOnUnauthorized: Bool
    
    @objc public init(cardCrypto: CardCrypto, accessTokenProvider: AccessTokenProvider, cardVerifier: CardVerifier) {
        self.cardCrypto = cardCrypto
        self.modelSigner = ModelSigner(crypto: cardCrypto)
        self.cardClient = CardClient()
        self.accessTokenProvider = accessTokenProvider
        self.cardVerifier = cardVerifier
        self.retryOnUnauthorized = true
        
        super.init()
    }
}
