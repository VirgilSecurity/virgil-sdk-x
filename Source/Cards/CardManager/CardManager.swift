//
//  CardManager.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Declares error types and codes for CardManager
///
/// - cardIsNotVerified: Virgil Card was not verified by cardVerifier
/// - gotWrongCard: Response Card doesn't match to what was queried
@objc(VSSCardManagerError) public enum CardManagerError: Int, Error {
    case cardIsNotVerified = 1
    case gotWrongCard = 2
}

/// Class responsible for operations with Virgil Cards
@objc(VSSCardManager) open class CardManager: NSObject {
    /// ModelSigner instance used for self signing Cards
    @objc public let modelSigner: ModelSigner
    /// CardCrypto instance
    @objc public let cardCrypto: CardCrypto
    /// AccessTokenProvider instance used for getting Access Token
    /// when performing queries
    @objc public let accessTokenProvider: AccessTokenProvider
    /// CardClient instance used for performing queries
    @objc public let cardClient: CardClientProtocol
    /// Card Verifier instance used for verifyng Cards
    @objc public let cardVerifier: CardVerifier
    /// Will automaticaly perform second query with forceReloaded = true AccessToken if true
    @objc public let retryOnUnauthorized: Bool
    /// Makes GenerickOperation with provided in initializer signCallback
    public let signModelOperationFabric: SignModelOperationFabric?

    /// Initializer
    ///
    /// - Parameter params: CardManagerParams with needed parameters
    @objc public init(params: CardManagerParams) {
        self.modelSigner = params.modelSigner
        self.cardCrypto = params.cardCrypto
        self.accessTokenProvider = params.accessTokenProvider
        self.cardClient = params.cardClient
        self.cardVerifier = params.cardVerifier
        self.retryOnUnauthorized = params.retryOnUnauthorized

        if let signCallback = params.signCallback {
            self.signModelOperationFabric = SignModelOperationFabric(callback: signCallback)
        }
        else {
            self.signModelOperationFabric = nil
        }

        super.init()
    }
}
