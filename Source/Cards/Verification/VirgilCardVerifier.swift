//
//  VirgilCardVerifier.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSVirgilCardVerifier) public class VirgilCardVerifier: NSObject, CardVerifier {
    @objc public static let virgilPublicKeyBase64 = "MCowBQYDK2VwAyEAr0rjTWlCLJ8q9em0og33grHEh/3vmqp0IewosUaVnQg="

    @objc public let crypto: CardCrypto
    @objc public let virgilPublicKey: PublicKey
    @objc public var verifySelfSignature: Bool = true
    @objc public var verifyVirgilSignature: Bool = true
    @objc public var whiteLists: [WhiteList]

    @objc public init?(crypto: CardCrypto, whiteLists: [WhiteList] = []) {
        self.whiteLists = whiteLists
        self.crypto = crypto

        guard let publicKeyData = Data(base64Encoded: VirgilCardVerifier.virgilPublicKeyBase64),
              let publicKey = try? crypto.importPublicKey(from: publicKeyData) else { return nil }

        self.virgilPublicKey = publicKey

        super.init()
    }

    @objc public func verifyCard(card: Card) -> Bool {
        return verifySelfSignature(card) && verifyVirgilSignature(card) && verifyWhitelistsSignatures(card)
    }

    private func verifySelfSignature(_ card: Card) -> Bool {
        if self.verifySelfSignature {
            return VirgilCardVerifier.verify(crypto: crypto, card: card, signer: "self",
                                             signerPublicKey: card.publicKey)
        }
        return true
    }

    private func verifyVirgilSignature(_ card: Card) -> Bool {
        if self.verifyVirgilSignature {
            return VirgilCardVerifier.verify(crypto: crypto, card: card, signer: "virgil",
                                             signerPublicKey: self.virgilPublicKey)
        }
        return true
    }

    private func verifyWhitelistsSignatures(_ card: Card) -> Bool {
        for whiteList in whiteLists {
            guard let signerInfo = whiteList.verifiersCredentials.first(where: {
                    Set<String>(card.signatures.map({ $0.signer })).contains($0.signer)
                  }),
                  let publicKey = try? crypto.importPublicKey(from: signerInfo.publicKey),
                  VirgilCardVerifier.verify(crypto: crypto, card: card, signer: signerInfo.signer,
                                            signerPublicKey: publicKey) else {
               return false
            }
        }
        return true
    }

    private class func verify(crypto: CardCrypto, card: Card, signer: String, signerPublicKey: PublicKey) -> Bool {
        guard let signature = card.signatures.first(where: { $0.signer == signer }),
              let cardSnapshot = try? card.getRawCard(crypto: crypto).contentSnapshot,
              crypto.verifySignature(signature.signature, of: cardSnapshot + signature.snapshot, with: signerPublicKey) else { return false }
        return true
    }
}
