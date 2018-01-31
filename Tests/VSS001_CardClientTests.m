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
#import "VSSTestUtils.h"

@interface VSS001_CardClientTests : XCTestCase

@property (nonatomic) VSSTestsConst       * consts;
@property (nonatomic) VSCVirgilCrypto     * crypto;
@property (nonatomic) VSCVirgilCardCrypto * cardCrypto;
@property (nonatomic) VSSTestUtils        * utils;
@property (nonatomic) VSSCardClient       * cardClient;

@end

@implementation VSS001_CardClientTests

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSCVirgilCrypto alloc] init];
    self.cardCrypto = [[VSCVirgilCardCrypto alloc] init];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL connection:nil];
}

- (void)tearDown {
    [super tearDown];
}


- (void)test001_CreateCard {
    NSError *error;
    VSCVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportVirgilPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    NSString *identity = @"identity";

    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    XCTAssert(error == nil && rawCard != nil);

    NSString *strToken = [self.utils getTokenWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responseRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil && responseRawCard != nil);
    
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:responseRawCard];
    XCTAssert(card != nil);
    
    VSSRawCardContent *responseContent = [[VSSRawCardContent alloc] initWithSnapshot:responseRawCard.contentSnapshot];
    
    XCTAssert([responseContent.publicKey      isEqualToString: content.publicKey]);
    XCTAssert([responseContent.previousCardId isEqualToString: content.previousCardId] || (responseContent.previousCardId == nil && content.previousCardId == nil));
    XCTAssert([responseContent.version        isEqualToString: content.version]);
    XCTAssert(responseContent.createdAt      == content.createdAt);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:responseContent and:content]);
               
    NSData *exportedPublicKeyCard = [self.crypto exportVirgilPublicKey:(VSCVirgilPublicKey *)card.publicKey];
    XCTAssert(error == nil);
    NSString *publicKeyBase64Card = [exportedPublicKeyCard base64EncodedStringWithOptions:0];
    
    NSLog(@"Message == %@", publicKeyBase64);
    NSLog(@"Message == %@", publicKeyBase64Card);
    
    XCTAssert([card.identity isEqualToString:identity]);
    XCTAssert([publicKeyBase64Card isEqualToString:publicKeyBase64]);
    XCTAssert(card.previousCardId == nil);
    XCTAssert(card.previousCard == nil);
    XCTAssert(card.isOutdated == false);
    XCTAssert([card.version isEqualToString:@"5.0"]);
    XCTAssert(card.createdAt == [NSDate dateWithTimeIntervalSince1970:content.createdAt]);
    
    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:nil];
    
    // FIXME
    verifier.verifyVirgilSignature = false;
    
    VSSValidationResult *result = [verifier verifyCardWithCard:card];
    XCTAssert([result isValid]);
}

-(void)test002_GetCard {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    NSString *strToken = [self.utils getTokenWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSCVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    NSData *exportedPublicKey = [self.crypto exportVirgilPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];

    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];

    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    XCTAssert(error == nil && rawCard != nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    XCTAssert(rawCard.signatures.count == 1);
    
    VSSRawSignedModel *publishedRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:publishedRawCard];
    XCTAssert(card != nil);
    
    VSSRawSignedModel *foundedRawCard = [self.cardClient getCardWithId:card.identifier token:strToken error:&error];
    VSSCard *foundedCard = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:foundedRawCard];
    XCTAssert(error == nil && foundedCard != nil);
    
    VSSRawCardContent *responseContent = [[VSSRawCardContent alloc] initWithSnapshot:foundedRawCard.contentSnapshot];
    XCTAssert([self.utils isRawCardContentEqualWithContent:content and:responseContent]);
    XCTAssert([self.utils isCardsEqualWithCard:card and:foundedCard]);
    
    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:nil];
    
    // FIXME
    verifier.verifyVirgilSignature = false;
    
    VSSValidationResult *result = [verifier verifyCardWithCard:foundedCard];
    XCTAssert([result isValid]);
}

-(void)test003_SearchCards {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    NSString *strToken = [self.utils getTokenWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSCVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportVirgilPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    XCTAssert(error == nil && rawCard != nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    XCTAssert(rawCard.signatures.count == 1);
    
    VSSRawSignedModel *publishedRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:publishedRawCard];
    XCTAssert(card != nil);
    
    NSArray<VSSRawSignedModel *> *foundedRawCards = [self.cardClient searchCardsWithIdentity:identity token:strToken error:&error];
    XCTAssert(foundedRawCards.count != 0);
    VSSRawSignedModel *foundedRawCard = foundedRawCards.firstObject;
    
    VSSCard *foundedCard = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:foundedRawCard];
    XCTAssert(error == nil && foundedCard != nil);
    
    VSSRawCardContent *responseContent = [[VSSRawCardContent alloc] initWithSnapshot:foundedRawCard.contentSnapshot];
    XCTAssert([self.utils isRawCardContentEqualWithContent:content and:responseContent]);
    XCTAssert([self.utils isCardsEqualWithCard:card and:foundedCard]);
    
    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:nil];
    
    // FIXME
    verifier.verifyVirgilSignature = false;
    
    VSSValidationResult *result = [verifier verifyCardWithCard:foundedCard];
    XCTAssert([result isValid]);
}

-(void)test004_PublishCard_With_wrongTokenIdentity {
    NSError *error;
    VSCVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportVirgilPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    NSString *identity = @"identity1";
    NSString *wrongIdentity = @"identity2";
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    XCTAssert(error == nil && rawCard != nil);
    
    NSString *strToken = [self.utils getTokenWithIdentity:wrongIdentity error:&error];
    XCTAssert(error == nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responseRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    
    //Services must fix it
    XCTAssert(error != nil);
    XCTAssert(responseRawCard == nil);
    
    NSLog(@"Message == %@", [error localizedDescription]);
}

-(void)test005_PublishCard_With_wrongTokenPrivateKey {
    NSError *error;
    VSCVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportVirgilPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    NSString *identity = @"identity1";
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    XCTAssert(error == nil && rawCard != nil);
    
    NSString *strToken = [self.utils getTokenWithWrongPrivateKeyWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responseRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error != nil);
    XCTAssert(responseRawCard == nil);
    XCTAssert([[error localizedDescription] isEqualToString:@"JWT is invalid"]);
}

@end
