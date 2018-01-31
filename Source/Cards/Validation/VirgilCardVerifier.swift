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
    @objc public static let ErrorDomain = "VSSVirgilCardVerifierErrorDomain"
    
    private static let virgilCardId          = "a3dda3d499d91d8287194d399f992c2317f9b6c529d9a0e4972c6e244c399f25"
    private static let virgilPublicKeyBase64 = "MCowBQYDK2VwAyEAr0rjTWlCLJ8q9em0og33grHEh/3vmqp0IewosUaVnQg="
    
    @objc public var crypto: CardCrypto
    @objc public var verifySelfSignature:   Bool = true
    @objc public var verifyVirgilSignature: Bool = true
    
    @objc public var whiteLists: [WhiteList]
    
    @objc public init(crypto: CardCrypto, whiteLists: [WhiteList]? = nil) {
        self.whiteLists = whiteLists ?? []
        self.crypto = crypto
    
        super.init()
    }
    
    @objc public func verifyCard(card: Card) -> ValidationResult {
        let result = ValidationResult()
        
        if self.verifySelfSignature {
            VirgilCardVerifier.validate(crypto: crypto, card: card, signerCardId: card.identifier, signerPublicKey: card.publicKey, signerType: .self, result: result)
        }
        
        if self.verifyVirgilSignature {
            if let publicKeyData = Data(base64Encoded: VirgilCardVerifier.virgilPublicKeyBase64),
                let publicKey = try? crypto.importPublicKey(from: publicKeyData) {
                    VirgilCardVerifier.validate(crypto: crypto, card: card, signerCardId: VirgilCardVerifier.virgilCardId, signerPublicKey: publicKey, signerType: .virgil, result: result)
            }
            else {
                result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Error importing Virgil Public Key"]))
            }
        }
        
        for whiteList in whiteLists {
            if let signerInfo = whiteList.verifiersCredentials.filter({ Set<String>(card.signatures.map({ $0.signerId  })).contains($0.id) }).first {
                if let publicKey = try? crypto.importPublicKey(from: signerInfo.publicKey) {
                    VirgilCardVerifier.validate(crypto: crypto, card: card, signerCardId: signerInfo.id, signerPublicKey: publicKey, signerType: .extra, result: result)
                }
                else {
                    result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Error importing Whitelist Public Key for \(signerInfo.id)"]))
                }
            }
            else {
                result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The card does not contain signature from specified Whitelist"]))
            }
        }
        
        return result
    }
    
    private class func validate(crypto: CardCrypto, card: Card, signerCardId: String, signerPublicKey: PublicKey, signerType: SignerType, result: ValidationResult) {
        guard let signature = card.signatures.first(where: { $0.signerId == signerCardId }) else {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The card does not contain the \(signerType) signature for \(signerCardId)"]))
            return
        }
        
        guard let cardSnapshot = try? card.getRawCard(crypto: crypto).contentSnapshot else  {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The card with id \(signerCardId) was corrupted"]))
            return
        }
        let extraDataSnapshot = Data(base64Encoded: signature.snapshot ?? "") ?? Data()
        
        guard let fingerprint = try? crypto.generateSHA256(for: cardSnapshot + extraDataSnapshot) else {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: " Generating SHA256 of card with id\(signerCardId) failed"]))
            return
        }
        
        do {
            try crypto.verifySignature(signature.signature, of: fingerprint, with: signerPublicKey)
        }
        catch {
            result.addError(NSError(domain: VirgilCardVerifier.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The \(signerType.rawValue) signature for \(signerCardId) is not valid"]))
        }
    }
}
