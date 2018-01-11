//
//  ExtendedValidator.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSVirgilCardVerifier) public class VirgilCardVerifier: NSObject, CardVerifier {
    @objc public static let ErrorDomain = "VSSExtendedValidatorErrorDomain"
    
    private static let virgilCardId = "3e29d43373348cfb373b7eae189214dc01d7237765e572db685839b64adca853"
    private static let virgilPublicKeyBase64 = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUNvd0JRWURLMlZ3QXlFQVlSNTAxa1YxdFVuZTJ1T2RrdzRrRXJSUmJKcmMyU3lhejVWMWZ1RytyVnM9Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo"
    
    @objc public var crypto: CardCrypto
    @objc public var ignoreSelfSignature: Bool = false
    @objc public var ignoreVirgilSignature: Bool = false
    
    @objc public let whiteList: [VerifierCredentials]
    
    @objc public init(crypto: CardCrypto, whiteList: [VerifierCredentials]) {
        self.whiteList = whiteList
        self.crypto = crypto
        
        super.init()
    }
    
    @objc public func verifyCard(card: Card) -> ValidationResult {
        let result = ValidationResult()
        
        if !self.ignoreSelfSignature {
            VirgilCardVerifier.validate(crypto: crypto, card: card, signerCardId: card.identifier, signerPublicKey: card.publicKey, signerKind: "Self", result: result)
        }
        
        if !self.ignoreVirgilSignature {
            if let publicKeyData = Data(base64Encoded: VirgilCardVerifier.virgilPublicKeyBase64),
                let publicKey = try? crypto.importPublicKey(from: publicKeyData) {
                    VirgilCardVerifier.validate(crypto: crypto, card: card, signerCardId: VirgilCardVerifier.virgilCardId, signerPublicKey: publicKey, signerKind: "Virgil", result: result)
            }
            else {
                result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Error importing Virgil Public Key"]))
            }
        }
        
        if let signerInfo = self.whiteList.filter({ Set<String>(card.signatures.map({ $0.signerId  })).contains($0.cardId) }).first {
            if let publicKey = try? crypto.importPublicKey(from: signerInfo.publicKey) {
                VirgilCardVerifier.validate(crypto: crypto, card: card, signerCardId: signerInfo.cardId, signerPublicKey: publicKey, signerKind: "Whitelist", result: result)
            }
            else {
                result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Error importing Whitelist Public Key for \(signerInfo.cardId)"]))
            }
        }
        else {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The card does not contain signature from specified Whitelist"]))
        }
        
        return result
    }
    
    private class func validate(crypto: CardCrypto, card: Card, signerCardId: String, signerPublicKey: PublicKey, signerKind: String, result: ValidationResult) {
        guard let signature = card.signatures.first(where: { $0.signerId == signerCardId }) else {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The card does not contain the \(signerKind) signature for \(signerCardId)"]))
            return
        }
        
        do {
            try crypto.verifySignature(signature.signature, of: card.fingerprint, with: signerPublicKey)
        }
        catch {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The \(signerKind) signature for \(signerCardId) is not valid"]))
        }
    }
}
