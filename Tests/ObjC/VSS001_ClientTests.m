//
//  VSS001_ClientTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"
#import "VSSTestsConst.h"

/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSTestsUtils *utils;
@property (nonatomic) VSSTestsConst *consts;

@end

@implementation VSS001_ClientTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    
    VSSServiceConfig *config = [VSSServiceConfig serviceConfigWithToken:self.consts.applicationToken];
    self.crypto = [[VSSCrypto alloc] init];
    VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
    XCTAssert([validator addVerifierWithId:self.consts.applicationId publicKeyData:[[NSData alloc] initWithBase64EncodedString:self.consts.applicationPublicKeyBase64 options:0]]);
    
    config.cardValidator = validator;
    
    self.client = [[VSSClient alloc] initWithServiceConfig:config];
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:self.crypto consts:self.consts];
}

- (void)tearDown {
    self.client = nil;
    self.crypto = nil;
    self.consts = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_CreateCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created."];
    
    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    
    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        XCTAssert([card.identifier length] > 0);
        XCTAssert([self.utils checkCard:card isEqualToCreateCardRequest:request]);
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test002_CreateCardWithData {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card with data should be created."];
    
    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequestWithData:@{
        @"customKey1" : @"customField1",
        @"customKey2" : @"customField2"}];
    
    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        XCTAssert([card.identifier length] > 0);
        XCTAssert([self.utils checkCard:card isEqualToCreateCardRequest:request]);
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test003_SearchCards {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Search should return 1 card which is equal to created card"];
    
    NSUInteger numberOfRequests = 2;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    
    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        VSSSearchCardsCriteria *searchCardsCriteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeApplication identityType:card.identityType identities:@[card.identity]];
        
        sleep(3);
        [self.client searchCardsUsingCriteria:searchCardsCriteria completion:^(NSArray<VSSCard *>* cards, NSError *error) {
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

- (void)test004_GetCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Get card request should return 1 card which is equal to created card"];
    
    NSUInteger numberOfRequests = 2;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    
    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        sleep(3);
        [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
            if (error != nil) {
                XCTFail(@"Expectation failed: %@", error);
                return;
            }
            
            XCTAssert(foundCard != nil);
            XCTAssert([self.utils checkCard:foundCard isEqualToCard:card]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test005_RevokeCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Virgil card should be revoked"];
    
    NSUInteger numberOfRequests = 3;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    
    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        VSSRevokeCardRequest *revokeRequest = [self.utils instantiateRevokeCardForCard:card];
        
        sleep(3);
        [self.client revokeCardWithRequest:revokeRequest completion:^(NSError *error) {
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
