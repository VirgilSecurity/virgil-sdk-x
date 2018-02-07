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
    @objc public let crypto: CardCrypto
    @objc public let accessTokenProvider: AccessTokenProvider
    @objc public let cardClient: CardClient
    @objc public let cardVerifier: CardVerifier
    @objc public let signCallback: ((RawSignedModel) -> (RawSignedModel))?

    @objc public init(crypto: CardCrypto, accessTokenProvider: AccessTokenProvider,
                      modelSigner: ModelSigner, cardClient: CardClient, cardVerifier: CardVerifier,
                      signCallback: ((RawSignedModel) -> (RawSignedModel))?) {

        self.crypto = crypto
        self.cardClient = cardClient
        self.cardVerifier = cardVerifier
        self.accessTokenProvider = accessTokenProvider
        self.signCallback = signCallback
        self.modelSigner = modelSigner
    }

    @objc public enum CardManagerError: Int, Error {
        case cardIsNotValid = 1
        case cardParsingFailed = 2
    }

    internal func verifyCard(_ card: Card) throws {
        guard cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotValid
        }
    }

    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey,
                                      identity: String, previousCardId: String? = nil,
                                      extraFields: [String: String]? = nil) throws -> RawSignedModel {

        let exportedPubKey = try crypto.exportPublicKey(publicKey).base64EncodedString()

        let cardContent = RawCardContent(identity: identity, publicKey: exportedPubKey,
                                         previousCardId: nil, createdAt: Date())

        let snapshot = try SnapshotUtils.takeSnapshot(of: cardContent)

        var rawCard = RawSignedModel(contentSnapshot: snapshot)

        var data: Data?
        if extraFields != nil {
            data = try JSONSerialization.data(withJSONObject: extraFields as Any, options: [])
        }

        try self.modelSigner.selfSign(model: rawCard, privateKey: privateKey, additionalData: data)

        if let signCallback = self.signCallback {
            rawCard = signCallback(rawCard)
        }

        return rawCard
    }

    internal func getToken(operation: String) throws -> AccessToken {
        do {
            let tokenContext = TokenContext(operation: operation, forceReload: false)
            return try self.accessTokenProvider.getToken(with: tokenContext)
        } catch {
            if let err = error as? CardClient.CardServiceError {
                if err.errorCode == 401 {
                    let tokenContext = TokenContext(operation: operation, forceReload: true)
                    return try self.accessTokenProvider.getToken(with: tokenContext)
                }
            }
            throw error
        }
    }
}

// Import export cards
public extension CardManager {
    @objc func importCard(string: String) -> Card? {
        guard let rawCard = RawSignedModel(base64Encoded: string) else {
            return nil
        }

        return Card.parse(crypto: self.crypto, rawSignedModel: rawCard)
    }

    @objc func importCard(json: Any) -> Card? {
        guard let rawCard = RawSignedModel(dict: json) else {
            return nil
        }

        return Card.parse(crypto: self.crypto, rawSignedModel: rawCard)
    }

    @objc func `import`(rawCard: RawSignedModel) -> Card? {
        return Card.parse(crypto: self.crypto, rawSignedModel: rawCard)
    }

    @objc func exportAsBase64String(card: Card) throws -> String {
        return try card.getRawCard(crypto: self.crypto).base64EncodedString()
    }

    @objc func exportAsJson(card: Card) throws -> Any {
        return try card.getRawCard(crypto: self.crypto).exportAsJson()
    }

    @objc func exportAsRawCard(card: Card) throws -> RawSignedModel {
        return try card.getRawCard(crypto: self.crypto)
    }
}
