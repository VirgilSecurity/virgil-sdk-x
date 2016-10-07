//
//  VK001_KeysClientTests.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VirgilSDK.h"

static NSString *const kApplicationToken = <#NSString: Application Access Token#>;
static NSString *const kApplicationPublicKeyBase64 = <# NSString: Application Public Key #>;
static NSString *const kApplicationPrivateKeyBase64 = <#NSString: Application Private Key in base64#>;
static NSString *const kApplicationPrivateKeyPassword = <#NSString: Application Private Key password#>;
static NSString *const kApplicationId = <#NSString: Application Id#>;


/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;

@end

@implementation VSS001_ClientTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];

    self.client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken];
    self.crypto = [[VSSCrypto alloc] init];
    self.continueAfterFailure = NO;
}

- (void)tearDown {
    self.client = nil;
    self.crypto = nil;
    
    [super tearDown];
}

- (void)test001_CreateCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created."];

    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCard *instantiatedCard = [self instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
        
        XCTAssert([card.identifier length] > 0);
        XCTAssert([self checkCard:instantiatedCard isEqualToCard:card]);
        
        VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
        [validator addVerifierWithId:kApplicationId publicKey:[[NSData alloc] initWithBase64EncodedString:kApplicationPublicKeyBase64 options:0]];

        BOOL isValid = [validator validateCard:card];

        XCTAssert(isValid);
        
        [ex fulfill];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test002_SearchCards {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Search should return 1 card that is equal to created card"];
    
    NSUInteger numberOfRequests = 2;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCard *instantiatedCard = [self instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
        
        VSSSearchCards *searchCards = [VSSSearchCards createWithScope:VSSCardScopeApplication identityType:card.data.identityType identities:@[card.data.identity]];
        
        [self.client searchCards:searchCards completion:^(NSArray<VSSCard *>* cards, NSError *error) {
            if (error != nil)
                XCTFail(@"Expectation failed: %@", error);
            
            XCTAssert([cards count] == 1);
            XCTAssert([self checkCard:cards[0] isEqualToCard:card]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test003_GetCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Get card request should return 1 card that is equal to created card"];
    
    NSUInteger numberOfRequests = 2;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCard *instantiatedCard = [self instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
        
        [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
            if (error != nil)
                XCTFail(@"Expectation failed: %@", error);
            
            XCTAssert(foundCard != nil);
            XCTAssert([foundCard.identifier isEqualToString:card.identifier]);
            XCTAssert([self checkCard:foundCard isEqualToCard:card]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test004_RevokeCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Virgil card should be revoked"];
    
    NSUInteger numberOfRequests = 3;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCard *instantiatedCard = [self instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
        
        VSSRevokeCard *revokeCard = [self instantiateRevokeCardForCard:card];

        [self.client revokeCard:revokeCard completion:^(NSError *error) {
            if (error != nil)
                XCTFail(@"Expectation failed: %@", error);
            
            [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
                XCTAssert(error != nil);
                XCTAssert(foundCard == nil);
                
                VSSError *vssError = (VSSError *)error;
                XCTAssert(vssError != nil);
                XCTAssert(vssError.code == 404);
                
                [ex fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (VSSCard * __nonnull)instantiateCard {
    VSSKeyPair *keyPair = [self.crypto generateKey];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = [[NSUUID UUID] UUIDString];
    NSString *identityType = kApplicationPrivateKeyPassword;
    VSSCard *card = [VSSCard createWithIdentity:identityValue identityType:identityType publicKey:exportedPublicKey];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:kApplicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKey:privateAppKeyData password:kApplicationPrivateKeyPassword];
    
    VSSRequestSigner *requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSError *error;
    [requestSigner applicationSignRequest:card withPrivateKey:keyPair.privateKey error:&error];
    [requestSigner authoritySignRequest:card appId:kApplicationId withPrivateKey:appPrivateKey error:&error];
    
    return card;
}

- (VSSRevokeCard * __nonnull)instantiateRevokeCardForCard:(VSSCard * __nonnull)card {
    VSSRevokeCard *revokeCard = [VSSRevokeCard createWithCardId:card.identifier reason:VSSCardRevocationReasonUnspecified];
    
    VSSRequestSigner *requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:kApplicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKey:privateAppKeyData password:kApplicationPrivateKeyPassword];
    
    NSError *error;
    [requestSigner authoritySignRequest:revokeCard appId:kApplicationId withPrivateKey:appPrivateKey error:&error];
    
    return revokeCard;
}

- (BOOL)checkCard:(VSSCard * __nonnull)card1 isEqualToCard:(VSSCard * __nonnull)card2 {
    BOOL equals = [card1.snapshot isEqualToData:card2.snapshot]
        && [card1.data.identityType isEqualToString:card2.data.identityType]
        && [card1.data.identity isEqualToString:card2.data.identity];

    return equals;
}

@end
