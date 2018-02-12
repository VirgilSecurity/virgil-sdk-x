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
    @objc public let retryOnUnauthorized: Bool
    @objc public let signCallback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> ()) -> ())?

    @objc public init(crypto: CardCrypto, accessTokenProvider: AccessTokenProvider, modelSigner: ModelSigner,
                      cardClient: CardClient, cardVerifier: CardVerifier, retryOnUnauthorized: Bool = true,
                      signCallback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> ()) -> ())?) {
        self.crypto = crypto
        self.cardClient = cardClient
        self.cardVerifier = cardVerifier
        self.accessTokenProvider = accessTokenProvider
        self.signCallback = signCallback
        self.modelSigner = modelSigner
        self.retryOnUnauthorized = retryOnUnauthorized
    }

    @objc public enum CardManagerError: Int, Error {
        case cardIsNotVerified = 1
        case cardIsCorrupted = 2
        case gotNilToken = 3
        case gotNilSignedRawCard = 4
        case gotWrongCard = 5
    }

    internal func verifyCard(_ card: Card) throws {
        guard cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
    }

    internal func getTokenSync(tokenContext: TokenContext) throws -> AccessToken {
        let group = DispatchGroup()
        var error: Error?
        var tokenStr: AccessToken?
        group.enter()
        self.accessTokenProvider.getToken(with: tokenContext) { token, err in
            error = err
            tokenStr = token
            group.leave()
        }
        group.wait()

        if let err = error {
            throw err
        }
        guard let token = tokenStr else {
            throw CardManagerError.gotNilToken
        }

        return token
    }

    internal func signSync(rawCard: RawSignedModel) throws -> RawSignedModel {
        if let signCallback = self.signCallback {
            let group = DispatchGroup()
            var error: Error?
            var tempRawCard: RawSignedModel?
            group.enter()

            signCallback(rawCard) { signedRawCard, err in
                error = err
                tempRawCard = signedRawCard
                group.leave()
            }
            group.wait()

            if let err = error {
                throw err
            }
            guard let signedRawCard = tempRawCard else {
                throw CardManagerError.gotNilSignedRawCard
            }

            return signedRawCard
        }
        return rawCard
    }

    @objc public func generateRawCard(privateKey: PrivateKey, publicKey: PublicKey,
                                      identity: String, previousCardId: String? = nil,
                                      extraFields: [String: String]? = nil) throws -> RawSignedModel {
        let exportedPubKey = try crypto.exportPublicKey(publicKey).base64EncodedString()

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

// Import export cards
public extension CardManager {
    @objc func importCard(string: String) throws -> Card {
        guard let rawCard = RawSignedModel.importFrom(base64Encoded: string),
              let card = Card.parse(crypto: self.crypto, rawSignedModel: rawCard) else {
            throw CardManagerError.cardIsCorrupted
        }
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        return card
    }

    @objc func importCard(json: Any) throws -> Card {
        guard let rawCard = RawSignedModel.importFrom(json: json),
              let card = Card.parse(crypto: self.crypto, rawSignedModel: rawCard) else {
                throw CardManagerError.cardIsCorrupted
        }
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        return card
    }

    @objc func importCard(from rawCard: RawSignedModel) throws -> Card {
        guard let card = Card.parse(crypto: self.crypto, rawSignedModel: rawCard) else {
            throw CardManagerError.cardIsCorrupted
        }
        guard self.cardVerifier.verifyCard(card: card) else {
            throw CardManagerError.cardIsNotVerified
        }
        return card
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
