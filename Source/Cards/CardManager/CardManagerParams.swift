//
//  CardManagerParams.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Contains parameters for initializing CardManager
@objc(VSSCardManagerParams) public final class CardManagerParams: NSObject {
    /// CardCrypto instance
    @objc public let cardCrypto: CardCrypto
    /// AccessTokenProvider instance used for getting Access Token
    /// when performing queries
    @objc public let accessTokenProvider: AccessTokenProvider
    /// Card Verifier instance used for verifyng Cards
    @objc public let cardVerifier: CardVerifier
    /// ModelSigner instance used for self signing Cards
    @objc public var modelSigner: ModelSigner
    /// CardClient instance used for performing queries
    @objc public var cardClient: CardClientProtocol
    /// Callback used for custom signing RawSignedModel, which takes RawSignedModel
    /// to sign and competion handler, called with signed RawSignedModel or provided error
    @objc public var signCallback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)?
    /// Will automaticaly perform second query with forceReloaded = true AccessToken if true
    @objc public var retryOnUnauthorized: Bool

    /// Initializer
    ///
    /// - Parameters:
    ///   - cardCrypto: CardCrypto instance
    ///   - accessTokenProvider: AccessTokenProvider instance for getting Access Token
    ///     when performing queries
    ///   - cardVerifier: Card Verifier instance for verifyng Cards
    @objc public init(cardCrypto: CardCrypto, accessTokenProvider: AccessTokenProvider, cardVerifier: CardVerifier) {
        self.cardCrypto = cardCrypto
        self.modelSigner = ModelSigner(cardCrypto: cardCrypto)
        self.cardClient = CardClient()
        self.accessTokenProvider = accessTokenProvider
        self.cardVerifier = cardVerifier
        self.retryOnUnauthorized = true

        super.init()
    }
}
