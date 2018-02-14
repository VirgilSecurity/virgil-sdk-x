//
//  CardManager.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class responsible for operations with Virgil Cards
@objc(VSSCardManager) public class CardManager: NSObject {
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

    /// Declares error types and codes for CardManager
    ///
    /// - cardIsNotVerified: Virgil Card was not verified by cardVerifier
    /// - gotWrongCard: in a result of query Virgil Card Service returned wrong Card
    @objc(VSSCardManagerError) public enum CardManagerError: Int, Error {
        case cardIsNotVerified = 1
        case gotWrongCard = 2
    }

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

    /// Generates self signed RawSignedModel
    ///
    /// - Parameters:
    ///   - privateKey: PrivateKey to self sign with
    ///   - publicKey: Public Key instance
    ///   - identity: identity (must be equal to token one when publishing Card)
    ///   - previousCardId: identifier of Virgil Card with same identity this Card will replace
    ///   - extraFields: Dictionary with extra data to sign with model
    /// - Returns: generated and self signed RawSignedModel
    /// - Throws: corresponding error
    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey,
                                      identity: String, previousCardId: String? = nil,
                                      extraFields: [String: String]? = nil) throws -> RawSignedModel {
        let exportedPubKey = try cardCrypto.exportPublicKey(publicKey)

        let cardContent = RawCardContent(identity: identity, publicKey: exportedPubKey,
                                         previousCardId: previousCardId, createdAt: Date())

        let snapshot = try JSONEncoder().encode(cardContent)

        let rawCard = RawSignedModel(contentSnapshot: snapshot)

        var data: Data?
        if extraFields != nil {
            data = try JSONSerialization.data(withJSONObject: extraFields as Any, options: [])
        }
        else {
            data = nil
        }

        try self.modelSigner.selfSign(model: rawCard, privateKey: privateKey, additionalData: data)

        return rawCard
    }
}
