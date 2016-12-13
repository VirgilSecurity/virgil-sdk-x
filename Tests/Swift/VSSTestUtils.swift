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
    
    func instantiateCreateCardRequest() -> VSSCreateCardRequest {
        let keyPair = self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(keyPair.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = self.consts.applicationIdentityType
        let request = VSSCreateCardRequest(identity: identityValue, identityType: identityType, publicKeyData: exportedPublicKey)
        
        let privateAppKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: self.consts.applicationPrivateKeyPassword)!
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        try! signer.selfSign(request, with: keyPair.privateKey)
        try! signer.authoritySign(request, forAppId: self.consts.applicationId, with: appPrivateKey)
        
        return request;
    }
    
    func instantiateCreateCardRequest(with data: [String : String]) -> VSSCreateCardRequest {
        let keyPair = self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(keyPair.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = self.consts.applicationIdentityType
        let request = VSSCreateCardRequest(identity: identityValue, identityType: identityType, publicKeyData: exportedPublicKey, data: data)
        
        let privateAppKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: self.consts.applicationPrivateKeyPassword)!
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        try! signer.selfSign(request, with: keyPair.privateKey)
        try! signer.authoritySign(request, forAppId: self.consts.applicationId, with: appPrivateKey)
        
        return request;
    }
    
    func check(card: VSSCard, isEqualToCreateCardRequest request: VSSCreateCardRequest) -> Bool {
        let equals = card.identityType == request.snapshotModel.identityType
            && card.identity == request.snapshotModel.identity
            && checkObjectsEqualOrBothNil(left: card.data, right: request.snapshotModel.data)
            && checkObjectsEqualOrBothNil(left: card.info, right: request.snapshotModel.info)
            && card.publicKeyData == request.snapshotModel.publicKeyData
            && card.scope == request.snapshotModel.scope
        
        return equals
    }
    
    func check(card card1: VSSCard, isEqualToCard card2: VSSCard) -> Bool {
        let equals = card1.identityType == card2.identityType
            && card1.identity == card2.identity
            && card1.identifier == card2.identifier
            && card1.createdAt == card2.createdAt
            && card1.cardVersion == card2.cardVersion
            && checkObjectsEqualOrBothNil(left: card1.data, right: card2.data)
            && checkObjectsEqualOrBothNil(left: card1.info, right: card2.info)
            && card1.publicKeyData == card2.publicKeyData
            && card1.scope == card2.scope
        
        return equals
    }
    
    func check(createCardRequest request1: VSSCreateCardRequest, isEqualToCreateCardRequest request2: VSSCreateCardRequest) -> Bool {
        let equals = request1.snapshot == request2.snapshot
            && request1.signatures == request2.signatures
            && checkObjectsEqualOrBothNil(left: request1.snapshotModel.data, right: request2.snapshotModel.data)
            && request1.snapshotModel.identity == request2.snapshotModel.identity
            && request1.snapshotModel.identityType == request2.snapshotModel.identityType
            && checkObjectsEqualOrBothNil(left: request1.snapshotModel.info, right: request2.snapshotModel.info)
            && request1.snapshotModel.publicKeyData == request2.snapshotModel.publicKeyData
            && request1.snapshotModel.scope == request2.snapshotModel.scope
        
        return equals
    }
    
    func instantiateRevokeCardRequestFor(card: VSSCard) -> VSSRevokeCardRequest {
        let revokeCard = VSSRevokeCardRequest(cardId: card.identifier, reason: .unspecified)
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        let privateAppKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: self.consts.applicationPrivateKeyPassword)!
        
        try! signer.authoritySign(revokeCard, forAppId: self.consts.applicationId, with: appPrivateKey)
        
        return revokeCard
    }
    
    func check(revokeCardRequest request1: VSSRevokeCardRequest, isEqualToRevokeCardRequest request2: VSSRevokeCardRequest) -> Bool {
        let equals = request1.snapshot == request2.snapshot
            && request1.signatures == request2.signatures
            && request1.snapshotModel.cardId == request2.snapshotModel.cardId
            && request1.snapshotModel.revocationReason == request2.snapshotModel.revocationReason
        
        return equals
    }
}

func checkObjectsEqualOrBothNil(left: Dictionary<String, String>?, right: Dictionary<String, String>?) -> Bool {
    if left == nil && right == nil {
        return true
    }
        
    guard let l = left, let r = right else {
        return false
    }
        
    return l == r
}
