//
//  VSS001_ClientTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSClient.h"
#import "VSSCrypto.h"
#import "VSSCardValidator.h"
#import "VSSRequestSigner.h"

#import "VSSTestsUtils.h"

/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSTestsUtils *utils;

@end

@implementation VSS001_ClientTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken];
    self.crypto = [[VSSCrypto alloc] init];
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:self.crypto];
}

- (void)tearDown {
    self.client = nil;
    self.crypto = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_CreateCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created."];
    
    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCard *instantiatedCard = [self.utils instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        XCTAssert([card.identifier length] > 0);
        XCTAssert([self.utils checkCard:instantiatedCard isEqualToCard:card]);
        
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
    
    VSSCard *instantiatedCard = [self.utils instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        VSSSearchCards *searchCards = [VSSSearchCards searchCardsWithScope:VSSCardScopeApplication identityType:card.data.identityType identities:@[card.data.identity]];
        
        [self.client searchCards:searchCards completion:^(NSArray<VSSCard *>* cards, NSError *error) {
            if (error != nil) {
                XCTFail(@"Expectation failed: %@", error);
                return;
            }
            
            XCTAssert([cards count] == 1);
            XCTAssert([self.utils checkCard:cards[0] isEqualToCard:card]);
            
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
    
    VSSCard *instantiatedCard = [self.utils instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
            if (error != nil) {
                XCTFail(@"Expectation failed: %@", error);
                return;
            }
            
            XCTAssert(foundCard != nil);
            XCTAssert([foundCard.identifier isEqualToString:card.identifier]);
            XCTAssert([self.utils checkCard:foundCard isEqualToCard:card]);
            
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
    
    VSSCard *instantiatedCard = [self.utils instantiateCard];
    
    [self.client createCard:instantiatedCard completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        VSSRevokeCard *revokeCard = [self.utils instantiateRevokeCardForCard:card];
        
        [self.client revokeCard:revokeCard completion:^(NSError *error) {
            if (error != nil) {
                XCTFail(@"Expectation failed: %@", error);
                return;
            }
            
            [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
                XCTAssert(foundCard == nil);
                
                XCTAssert(error != nil);
                XCTAssert(error.code == 404);
                
                [ex fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
