//
//  CardManager.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCardManager) public class CardManager: NSObject {
    @objc public let modelSigner: ModelSigner
    @objc public let cardCrypto: CardCrypto
    @objc public let accessTokenProvider: AccessTokenProvider
    @objc public let cardClient: CardClientProtocol
    @objc public let cardVerifier: CardVerifier
    @objc public let retryOnUnauthorized: Bool
    public let signModelOperationFabric: SignModelOperationFabric?

    @objc(VSSCardManagerError) public enum CardManagerError: Int, Error {
        case cardIsNotVerified = 1
        case cardIsCorrupted = 2
        case gotNilToken = 3
        case gotNilSignedRawCard = 4
        case gotWrongCard = 5
    }

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

    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey,
                                      identity: String, previousCardId: String? = nil,
                                      extraFields: [String: String]? = nil) throws -> RawSignedModel {
        let exportedPubKey = try cardCrypto.exportPublicKey(publicKey).base64EncodedString()

        let cardContent = RawCardContent(identity: identity, publicKey: exportedPubKey,
                                         previousCardId: previousCardId, createdAt: Date())

        let snapshot = try JSONEncoder().encode(cardContent)

        let rawCard = RawSignedModel(contentSnapshot: snapshot)

        var data: Data?
        if extraFields != nil {
            data = try JSONSerialization.data(withJSONObject: extraFields as Any, options: [])
        }

        try self.modelSigner.selfSign(model: rawCard, privateKey: privateKey, additionalData: data)

        return rawCard
    }
}
