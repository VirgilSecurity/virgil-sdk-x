//
//  VSSTestUtils.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation

let kApplicationToken = <#String: Application Access Token#>
let kApplicationPublicKeyBase64 = <#String: Application Public Key#>
let kApplicationPrivateKeyBase64 = <#String: Application Private Key in base64#>
let kApplicationPrivateKeyPassword = <#String: Application Private Key password#>
let kApplicationIdentityType = String: <#Application Identity Type#>
let kApplicationId = <#String: Application Id#>

class VSSTestUtils {
    private var crypto: VSSCrypto
    
    init(crypto: VSSCrypto) {
        self.crypto = crypto
    }
    
    func instantiateCard() -> VSSCard? {
        let keyPair = self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(keyPair.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = kApplicationIdentityType
        let card = VSSCard(identity: identityValue, identityType: identityType, publicKey: exportedPublicKey)
        
        let privateAppKeyData = Data(base64Encoded: kApplicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(privateAppKeyData, password: kApplicationPrivateKeyPassword)!
        
        let requestSigner = VSSRequestSigner(crypto: self.crypto)
        
        do {
            try requestSigner.applicationSignRequest(card, with: keyPair.privateKey)
            try requestSigner.authoritySignRequest(card, appId: kApplicationId, with: appPrivateKey)
        }
        catch _ {
            return nil
        }
        
        return card;
    }
    
    func check(card card1: VSSCard, isEqualToCard card2: VSSCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.identityType == card2.data.identityType
            && card1.data.identity == card2.data.identity
        
        return equals
    }
    
    func instantiateRevokeCardFor(card: VSSCard) -> VSSRevokeCard {
        let revokeCard = VSSRevokeCard(id: card.identifier!, reason: .unspecified)
        
        let requestSigner = VSSRequestSigner(crypto: self.crypto)
        
        let privateAppKeyData = Data(base64Encoded: kApplicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        
        let appPrivateKey = self.crypto.importPrivateKey(privateAppKeyData, password: nil)!
        
        do {
            try requestSigner.authoritySignRequest(revokeCard, appId: kApplicationId, with: appPrivateKey)
        }
        catch {}
        
        return revokeCard
    }
    
    func check(card card1: VSSRevokeCard, isEqualToCard card2: VSSRevokeCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.cardId == card2.data.cardId
        
        return equals
    }
}
