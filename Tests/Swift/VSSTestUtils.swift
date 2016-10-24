//
//  VSSTestUtils.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK

class VSSTestUtils {
    private var crypto: VSSCrypto
    private var consts: VSSTestsConst
    
    init(crypto: VSSCrypto, consts: VSSTestsConst) {
        self.crypto = crypto
        self.consts = consts
    }
    
    func instantiateCard() -> VSSCard? {
        let keyPair = self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(keyPair.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = self.consts.applicationIdentityType
        let card = VSSCard(identity: identityValue, identityType: identityType, publicKey: exportedPublicKey)
        
        let privateAppKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: self.consts.applicationPrivateKeyPassword)!
        
        let signer = VSSSigner(crypto: self.crypto)
        
        try! signer.ownerSign(card, with: keyPair.privateKey)
        try! signer.authoritySign(card, forAppId: self.consts.applicationId, with: appPrivateKey)
        
        return card;
    }
    
    func check(card card1: VSSCard, isEqualToCard card2: VSSCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.identityType == card2.data.identityType
            && card1.data.identity == card2.data.identity
        
        return equals
    }
    
    func instantiateRevokeCardFor(card: VSSCard) -> VSSRevokeCard {
        let revokeCard = VSSRevokeCard(cardId: card.identifier!, reason: .unspecified)
        
        let signer = VSSSigner(crypto: self.crypto)
        
        let privateAppKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: self.consts.applicationPrivateKeyPassword)!
        
        try! signer.authoritySign(revokeCard, forAppId: self.consts.applicationId, with: appPrivateKey)
        
        return revokeCard
    }
    
    func check(card card1: VSSRevokeCard, isEqualToCard card2: VSSRevokeCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.cardId == card2.data.cardId
        
        return equals
    }
}
