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
    
    func instantiateCreateCardRequest(keyPair: VSSKeyPair? = nil) -> VSSCreateCardRequest {
        let kp = keyPair ?? self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(kp.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = self.consts.applicationIdentityType
        let request = VSSCreateCardRequest(identity: identityValue, identityType: identityType, publicKeyData: exportedPublicKey)
        
        let privateAppKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: self.consts.applicationPrivateKeyPassword)!
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        try! signer.selfSign(request, with: kp.privateKey)
        try! signer.authoritySign(request, forAppId: self.consts.applicationId, with: appPrivateKey)
        
        return request;
    }
    
    func instantiateEmailCreateCardRequest(withIdentity identity: String, validationToken: String, keyPair: VSSKeyPair?) -> VSSCreateGlobalCardRequest {
        let kp = keyPair ?? self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(kp.publicKey)
        
        let identityValue = identity
        let identityType = "email"
        let request = VSSCreateGlobalCardRequest(identity: identityValue, identityType: identityType, validationToken:validationToken, publicKeyData: exportedPublicKey)
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        try! signer.selfSign(request, with: kp.privateKey)
        
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
    
    func instantiateCard() -> VSSCard {
        let dataStr = "{\"id\": \"9846238f5a5a60c81ae416e7bd8e06e38e6e77fbdbd0b79f695c3ee743e70193\",\"content_snapshot\": \"eyJwdWJsaWNfa2V5IjoiTUNvd0JRWURLMlZ3QXlFQWJcL2xLbU9xUVdnTkR6dktEb1BjY1FYbm9LOTN0UXFcLzl5VDg0bFwveTUrNVU9IiwiaWRlbnRpdHkiOiI3RUU0RTE4Ri01MkQ0LTQ4QzEtODZEQy0yOUY5ODg0MDdGREUiLCJpZGVudGl0eV90eXBlIjoidGVzdCIsInNjb3BlIjoiYXBwbGljYXRpb24ifQ==\",\"meta\": {\"created_at\": \"2017-01-26T15:39:28+0200\",\"card_version\": \"4.0\",\"signs\": {\"3e29d43373348cfb373b7eae189214dc01d7237765e572db685839b64adca853\": \"MFEwDQYJYIZIAWUDBAICBQAEQEwyX32OEO6HKtlMAru6ebQLHcoORId2Qn2nQSxAXJyHs+nZESZW6EKpclYFlptlV6I1NxeAefBJdVg9WObzxQ8=\",\"9846238f5a5a60c81ae416e7bd8e06e38e6e77fbdbd0b79f695c3ee743e70193\": \"MFEwDQYJYIZIAWUDBAICBQAEQDzVWVYU3s+b0FbaIYaiH34G/aJL50ExPz/t3RpE8lmmgoDFM8nTAqYrbnBeNJhhW6th8VboWk0qbIPTg6JsXgQ=\",\"e20830b806e54433950edd67e83578a5a2dadb1edf60300f180cc22eea7ea519\": \"MFEwDQYJYIZIAWUDBAICBQAEQI2un2U3xQa+xU4gMSwp3+6V4huzKKFayhAwAMRvph1fVkT/coP/SSQtgl1xBF1cFH3PdvMXcOmaDeqnhnaFUAg=\"}}}"
            
        let data = dataStr.data(using: .utf8)!
        
        let jsonObj = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let cardResponse = VSSCardResponse(dict: jsonObj as! [AnyHashable : Any])!
        
        return cardResponse.buildCard();
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
    
    func check(card: VSSCard, isEqualToCreateCardRequest request: VSSCreateGlobalCardRequest) -> Bool {
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
    
    func check(createGlobalCardRequest request1: VSSCreateGlobalCardRequest, isEqualToCreateGlobalCardRequest request2: VSSCreateGlobalCardRequest) -> Bool {
        let equals = request1.snapshot == request2.snapshot
            && request1.signatures == request2.signatures
            && checkObjectsEqualOrBothNil(left: request1.snapshotModel.data, right: request2.snapshotModel.data)
            && request1.snapshotModel.identity == request2.snapshotModel.identity
            && request1.snapshotModel.identityType == request2.snapshotModel.identityType
            && checkObjectsEqualOrBothNil(left: request1.snapshotModel.info, right: request2.snapshotModel.info)
            && request1.snapshotModel.publicKeyData == request2.snapshotModel.publicKeyData
            && request1.snapshotModel.scope == request2.snapshotModel.scope
            && request1.validationToken == request2.validationToken
            && !request1.validationToken.isEmpty
        
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
    
    func instantiateRevokeGlobalCardRequestFor(card: VSSCard, validationToken: String, privateKey: VSSPrivateKey) -> VSSRevokeGlobalCardRequest {
        let revokeCard = VSSRevokeGlobalCardRequest(cardId: card.identifier, validationToken:validationToken, reason: .unspecified)
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        try! signer.authoritySign(revokeCard, forAppId: card.identifier, with: privateKey)
        
        return revokeCard
    }
    
    func check(revokeCardRequest request1: VSSRevokeCardRequest, isEqualToRevokeCardRequest request2: VSSRevokeCardRequest) -> Bool {
        let equals = request1.snapshot == request2.snapshot
            && request1.signatures == request2.signatures
            && request1.snapshotModel.cardId == request2.snapshotModel.cardId
            && request1.snapshotModel.revocationReason == request2.snapshotModel.revocationReason
        
        return equals
    }
    
    func check(revokeGlobalCardRequest request1: VSSRevokeGlobalCardRequest, isEqualToRevokeGlobalCardRequest request2: VSSRevokeGlobalCardRequest) -> Bool {
        let equals = request1.snapshot == request2.snapshot
            && request1.signatures == request2.signatures
            && request1.snapshotModel.cardId == request2.snapshotModel.cardId
            && request1.snapshotModel.revocationReason == request2.snapshotModel.revocationReason
            && request1.validationToken == request2.validationToken
            && !request1.validationToken.isEmpty
        
        return equals
    }
    
    func generateEmail() -> String {
        let candidate = UUID().uuidString.lowercased();
        let identityLong = candidate.replacingOccurrences(of: "-", with: "")
        let identity = identityLong.substring(to: identityLong.index(identityLong.startIndex, offsetBy: 25))
        
        return String(format: "%@@mailinator.com", identity)
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
