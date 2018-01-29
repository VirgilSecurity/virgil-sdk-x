//
//  VSS001_CardClientTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCrypto;

#import "VSSTestsConst.h"

@interface VSS001_CardClientTests : XCTestCase

@end

@implementation VSS001_CardClientTests

- (void)test001_CreateCard {
    VSSTestsConst *consts = [[VSSTestsConst alloc] init];
    
    VSSCardClient *cardClient = [[VSSCardClient alloc] initWithServiceUrl:consts.serviceURL connection:nil];
    VSCVirgilCrypto *crypto = [[VSCVirgilCrypto alloc] init];
    
    VSCVirgilPrivateKeyExporter *exporter = [[VSCVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:crypto password:nil];

    NSData *privKey = [[NSData alloc] initWithBase64EncodedString:consts.accessPrivateKeyBase64 options:0];
    XCTAssert(privKey != nil);
    
    NSError *error;
    VSCVirgilPrivateKey *privateKey = (VSCVirgilPrivateKey *)[exporter importPrivateKeyFrom:privKey error:&error];
    XCTAssert(error == nil);
    
    VSCVirgilAccessTokenSigner *tokenSigner = [[VSCVirgilAccessTokenSigner alloc] init];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:consts.applicationId ttl:1000];
    
    NSString *identity = @"identity";
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:identity additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    NSString *strToken = [jwtToken stringRepresentation];
    XCTAssert(error == nil);
    
    NSData *pubKey = [[NSData alloc] initWithBase64EncodedString:consts.accessPublicKeyBase64 options:0];
    VSCVirgilPublicKey *key =  [crypto importVirgilPublicKeyFrom:pubKey];
    XCTAssert(error == nil);
    
    VSSJwtVerifier *verifier = [[VSSJwtVerifier alloc] initWithApiPublicKey:key apiPublicKeyIdentifier:consts.accessPublicKeyId accessTokenSigner:tokenSigner];
    
    [verifier verifyTokenWithJwtToken:jwtToken error:&error];
    XCTAssert(error == nil);

    VSCVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [crypto exportVirgilPublicKey:keyPair.publicKey];
    XCTAssert(error == nil);

    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];

    NSLocale *currentLocale = [NSLocale currentLocale];
    XCTAssert(currentLocale != nil);
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    XCTAssert(content != nil);
    
    NSData *snapshot = [content snapshot];
    XCTAssert(snapshot != nil);
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    XCTAssert(rawCard != nil);
    
    VSCVirgilCardCrypto *cardCrypto = [[VSCVirgilCardCrypto alloc] init];
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:cardCrypto];
    
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responceRawCard = [cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil);
    XCTAssert(responceRawCard != nil);
    
    VSSCard *card = [VSSCard parseWithCrypto:cardCrypto rawSignedModel:responceRawCard];
    XCTAssert(card != nil);
    
    NSData *exportedPublicKeyCard = [crypto exportVirgilPublicKey:(VSCVirgilPublicKey *)card.publicKey];
    XCTAssert(error == nil);
    
    NSString *publicKeyBase64Card = [exportedPublicKeyCard base64EncodedStringWithOptions:0];
    
    VSSRawCardContent *responseContent = [[VSSRawCardContent alloc] initWithSnapshot:responceRawCard.contentSnapshot];
    NSLog(@"Message == %@", responseContent.publicKey);
    XCTAssert([responseContent.publicKey isEqualToString:publicKeyBase64]);
    
    NSLog(@"Message == %@", publicKeyBase64);
    NSLog(@"Message == %@", publicKeyBase64Card);
    
    XCTAssert([card.identity isEqualToString:identity]);
    XCTAssert([publicKeyBase64Card isEqualToString:publicKeyBase64]);
    XCTAssert(card.previousCardId == nil);
    XCTAssert(card.previousCard == nil);
    XCTAssert(card.isOutdated == false);
    XCTAssert([card.version isEqualToString:@"5.0"]);
    XCTAssert(card.createdAt == [NSDate dateWithTimeIntervalSince1970:content.createdAt]);
}

@end
