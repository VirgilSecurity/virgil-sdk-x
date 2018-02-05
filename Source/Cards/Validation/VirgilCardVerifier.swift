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
    private static let virgilPublicKeyBase64 = "MCowBQYDK2VwAyEAr0rjTWlCLJ8q9em0og33grHEh/3vmqp0IewosUaVnQg="
    
    @objc public var crypto: CardCrypto
    @objc public var verifySelfSignature: Bool = true
    @objc public var verifyVirgilSignature: Bool = true
    
    private var virgilPublicKey: PublicKey? = nil
    
    @objc public var whiteLists: [WhiteList]
    
    @objc public init(crypto: CardCrypto, whiteLists: [WhiteList]? = nil) {
        self.whiteLists = whiteLists ?? []
        self.crypto = crypto
    
        if let publicKeyData = Data(base64Encoded: VirgilCardVerifier.virgilPublicKeyBase64) {
            self.virgilPublicKey = try? crypto.importPublicKey(from: publicKeyData)
        }
        
        super.init()
    }
    
    @objc public func verifyCard(card: Card) -> Bool {
        return verifySelf(card) && verifyVirgil(card) && verifyWhitelists(card)
    }
    
    private func verifySelf(_ card: Card) -> Bool {
        if self.verifySelfSignature {
            return VirgilCardVerifier.verify(crypto: crypto, card: card, signer: "self", signerPublicKey: card.publicKey)
        }
        return true
    }
    
    private func verifyVirgil(_ card: Card) -> Bool {
        if self.verifyVirgilSignature {
            if let publicKey = self.virgilPublicKey {
                return VirgilCardVerifier.verify(crypto: crypto, card: card, signer: "virgil", signerPublicKey: publicKey)
            }
        }
        return true
    }
    
    private func verifyWhitelists(_ card: Card) -> Bool {
        for whiteList in whiteLists {
            guard let signerInfo = whiteList.verifiersCredentials.filter({ Set<String>(card.signatures.map({ $0.signer })).contains($0.signer) }).first,
                  let publicKey = try? crypto.importPublicKey(from: signerInfo.publicKey),
                  VirgilCardVerifier.verify(crypto: crypto, card: card, signer: signerInfo.signer, signerPublicKey: publicKey) else
            {
               return false
            }
        }
        return true
    }
    
    private class func verify(crypto: CardCrypto, card: Card, signer: String, signerPublicKey: PublicKey) -> Bool {
        guard let signature = card.signatures.first(where: { $0.signer == signer }),
              let cardSnapshot = try? card.getRawCard(crypto: crypto).contentSnapshot,
              let fingerprint = try? crypto.generateSHA256(for: cardSnapshot + signature.snapshot),
              crypto.verifySignature(signature.signature, of: fingerprint, with: signerPublicKey) else { return false }
        return true
    }
}
