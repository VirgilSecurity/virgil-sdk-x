//
//  VSSTestsCommon.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSTestsUtils.h"
#import "PrivateApiDecl.h"

#define IsDataEqualOrBothNil(x,y) ((x && [x isEqualToData:y]) || (!x && !y))
#define IsDictionaryEqualOrBothNil(x,y) ((x && [x isEqualToDictionary:y]) || (!x && !y))
#define IsStringEqualOrBothNil(x,y) ((x && [x isEqualToString:y]) || (!x && !y))

@implementation VSSTestsUtils

- (instancetype)initWithCrypto:(VSSCrypto *)crypto consts:(VSSTestsConst *)consts {
    self = [super init];
    if (self) {
        _crypto = crypto;
        _consts = consts;
    }
    
    return self;
}

- (VSSCreateCardRequest *)instantiateCreateCardRequest {
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = [[NSUUID UUID] UUIDString];
    NSString *identityType = self.consts.applicationIdentityType;
    VSSCreateCardRequest *request = [VSSCreateCardRequest createCardRequestWithIdentity:identityValue identityType:identityType publicKeyData:exportedPublicKey];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKeyFromData:privateAppKeyData withPassword:self.consts.applicationPrivateKeyPassword];
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSError *error;
    [signer selfSignRequest:request withPrivateKey:keyPair.privateKey error:&error];
    [signer authoritySignRequest:request forAppId:self.consts.applicationId withPrivateKey:appPrivateKey error:&error];
    
    return request;
}

- (VSSCreateGlobalCardRequest *)instantiateEmailCreateCardRequestWithIdentity:(NSString *)identity {
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = identity;
    NSString *identityType = @"email";
    VSSCreateGlobalCardRequest *request = [VSSCreateGlobalCardRequest createCardRequestWithIdentity:identityValue identityType:identityType publicKeyData:exportedPublicKey];
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSError *error;
    [signer selfSignRequest:request withPrivateKey:keyPair.privateKey error:&error];
    
    return request;
}

- (VSSCard *)instantiateCard {
    NSString *dataStr = @"{\"id\": \"9846238f5a5a60c81ae416e7bd8e06e38e6e77fbdbd0b79f695c3ee743e70193\",\"content_snapshot\": \"eyJwdWJsaWNfa2V5IjoiTUNvd0JRWURLMlZ3QXlFQWJcL2xLbU9xUVdnTkR6dktEb1BjY1FYbm9LOTN0UXFcLzl5VDg0bFwveTUrNVU9IiwiaWRlbnRpdHkiOiI3RUU0RTE4Ri01MkQ0LTQ4QzEtODZEQy0yOUY5ODg0MDdGREUiLCJpZGVudGl0eV90eXBlIjoidGVzdCIsInNjb3BlIjoiYXBwbGljYXRpb24ifQ==\",\"meta\": {\"created_at\": \"2017-01-26T15:39:28+0200\",\"card_version\": \"4.0\",\"signs\": {\"3e29d43373348cfb373b7eae189214dc01d7237765e572db685839b64adca853\": \"MFEwDQYJYIZIAWUDBAICBQAEQEwyX32OEO6HKtlMAru6ebQLHcoORId2Qn2nQSxAXJyHs+nZESZW6EKpclYFlptlV6I1NxeAefBJdVg9WObzxQ8=\",\"9846238f5a5a60c81ae416e7bd8e06e38e6e77fbdbd0b79f695c3ee743e70193\": \"MFEwDQYJYIZIAWUDBAICBQAEQDzVWVYU3s+b0FbaIYaiH34G/aJL50ExPz/t3RpE8lmmgoDFM8nTAqYrbnBeNJhhW6th8VboWk0qbIPTg6JsXgQ=\",\"e20830b806e54433950edd67e83578a5a2dadb1edf60300f180cc22eea7ea519\": \"MFEwDQYJYIZIAWUDBAICBQAEQI2un2U3xQa+xU4gMSwp3+6V4huzKKFayhAwAMRvph1fVkT/coP/SSQtgl1xBF1cFH3PdvMXcOmaDeqnhnaFUAg=\"}}}";
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    VSSCardResponse *cardResponse = [[VSSCardResponse alloc] initWithDict:jsonObj];
    
    return [cardResponse buildCard];
}

- (VSSCreateCardRequest *)instantiateCreateCardRequestWithData:(NSDictionary<NSString *, NSString *> *)data {
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = [[NSUUID UUID] UUIDString];
    NSString *identityType = self.consts.applicationIdentityType;
    VSSCreateCardRequest *request = [VSSCreateCardRequest createCardRequestWithIdentity:identityValue identityType:identityType publicKeyData:exportedPublicKey data:data];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKeyFromData:privateAppKeyData withPassword:self.consts.applicationPrivateKeyPassword];
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSError *error;
    [signer selfSignRequest:request withPrivateKey:keyPair.privateKey error:&error];
    [signer authoritySignRequest:request forAppId:self.consts.applicationId withPrivateKey:appPrivateKey error:&error];
    
    return request;
}

- (VSSRevokeCardRequest *)instantiateRevokeCardForCard:(VSSCard * __nonnull)card {
    VSSRevokeCardRequest *request = [VSSRevokeCardRequest revokeCardRequestWithCardId:card.identifier reason:VSSCardRevocationReasonUnspecified];
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKeyFromData:privateAppKeyData withPassword:self.consts.applicationPrivateKeyPassword];
    
    NSError *error;
    [signer authoritySignRequest:request forAppId:self.consts.applicationId withPrivateKey:appPrivateKey error:&error];
    
    return request;
}

- (BOOL)checkCard:(VSSCard *)card isEqualToCreateCardRequest:(VSSCreateCardRequest *)request {
    BOOL equals = [card.identityType isEqualToString:request.snapshotModel.identityType]
        && [card.identity isEqualToString:request.snapshotModel.identity]
        && IsDictionaryEqualOrBothNil(card.data, request.snapshotModel.data)
        && IsDictionaryEqualOrBothNil(card.info, request.snapshotModel.info)
        && [card.publicKeyData isEqualToData:request.snapshotModel.publicKeyData]
        && card.scope == request.snapshotModel.scope;
    
    return equals;
}

- (BOOL)checkCard:(VSSCard *)card1 isEqualToCard:(VSSCard *)card2 {
    BOOL equals = [card1.identityType isEqualToString:card2.identityType]
        && [card1.identity isEqualToString:card2.identity]
        && [card1.identifier isEqualToString:card2.identifier]
        && [card1.createdAt isEqualToDate:card2.createdAt]
        && [card1.cardVersion isEqualToString:card2.cardVersion]
        && IsDictionaryEqualOrBothNil(card1.data, card2.data)
        && IsDictionaryEqualOrBothNil(card1.info, card2.info)
        && [card1.publicKeyData isEqualToData:card2.publicKeyData]
        && card1.scope == card2.scope;
    
    return equals;
}


- (BOOL)checkCreateCardRequest:(VSSCreateCardRequest *)request1 isEqualToCreateCardRequest:(VSSCreateCardRequest *)request2 {
    BOOL equals = [request1.snapshot isEqualToData:request2.snapshot]
        && [request1.signatures isEqualToDictionary:request2.signatures]
        && IsDictionaryEqualOrBothNil(request1.snapshotModel.data, request2.snapshotModel.data)
        && [request1.snapshotModel.identity isEqualToString:request2.snapshotModel.identity]
        && [request1.snapshotModel.identityType isEqualToString:request2.snapshotModel.identityType]
        && IsDictionaryEqualOrBothNil(request1.snapshotModel.info, request2.snapshotModel.info)
        && [request1.snapshotModel.publicKeyData isEqualToData:request2.snapshotModel.publicKeyData]
        && request1.snapshotModel.scope == request2.snapshotModel.scope;
    
    return equals;
}

- (BOOL)checkRevokeCardRequest:(VSSRevokeCardRequest *)request1 isEqualToRevokeCardRequest:(VSSRevokeCardRequest *)request2 {
    BOOL equals = [request1.snapshot isEqualToData:request2.snapshot]
        && [request1.signatures isEqualToDictionary:request2.signatures]
        && [request1.snapshotModel.cardId isEqualToString:request2.snapshotModel.cardId]
        && request1.snapshotModel.revocationReason == request2.snapshotModel.revocationReason;

    return equals;
}

- (NSString *)generateEmail {
    NSString *candidate = [[[NSUUID UUID] UUIDString] lowercaseString];
    NSString *identity = [[candidate stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:25];
    return [NSString stringWithFormat:@"%@@mailinator.com", identity];
}

@end
