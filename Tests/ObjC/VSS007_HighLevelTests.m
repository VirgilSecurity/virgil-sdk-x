//
//  VSS007_HighLevelTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"

/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;

@interface VSS007_HighLevelTests : XCTestCase

//@property (nonatomic) VSSTestsConst *consts;
//@property (nonatomic) VSSTestsUtils *utils;
//@property (nonatomic) VSSVirgilKey *key;
//@property (nonatomic) VSSVirgilAuthorityKey *authorityKey;

@end

@implementation VSS007_HighLevelTests

#pragma mark - Setup

//- (void)setUp {
//    [super setUp];
//    
//    self.consts = [[VSSTestsConst alloc] init];
//    self.utils = [[VSSTestsUtils alloc] initWithCrypto:[[VSSCrypto alloc] init] consts:self.consts];
//    
//    [VSSVirgilConfig initializeWithApplicationToken:self.consts.applicationToken];
//    
//    NSData *appPrivateKey = [[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0];
//    self.authorityKey = [VSSVirgilAuthorityKey virgilAuthorityKeyWithData:appPrivateKey password:self.consts.applicationPrivateKeyPassword forAppId:self.consts.applicationId];
//}
//
//- (void)tearDown {
//    self.consts = nil;
//    self.authorityKey = nil;
//    self.key = nil;
//    
//    [super tearDown];
//}
//
//- (void)test001_CreateCard {
//    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created."];
//    
//    NSUInteger numberOfRequests = 1;
//    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
//    
//    NSString *uuidStr = [[NSUUID UUID] UUIDString];
//    
//    self.key = [VSSVirgilKey virgilKeyWithName:uuidStr];
//    
//    XCTAssert(self.key != nil);
//    
//    NSError *error;
//    VSSCreateCardRequest *request = [self.key buildCreateCardRequestWithIdentity:uuidStr identityType:self.consts.applicationIdentityType data:nil error:&error];
//    XCTAssert(request != nil);
//    XCTAssert(error == nil);
//    
//    [self.authorityKey signRequest:request error:&error];
//    XCTAssert(error == nil);
//    
//    [VSSVirgilCard createCardWithRequest:request completion:^(VSSVirgilCard *card, NSError *error) {
//        XCTAssert(card != nil);
//        XCTAssert(error == nil);
//        
//        XCTAssert([card.identifier length] > 0);
//        XCTAssert([self.utils checkVirgilCard:card isEqualToCreateCardRequest:request]);
//        
//        [ex fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        XCTAssert(error == nil);
//    }];
//}
////
//- (void)test002_CreateCardWithData {
//    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card with data should be created."];
//    
//    NSUInteger numberOfRequests = 1;
//    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
//    
//    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequestWithData:@{
//                                                                                       @"customKey1" : @"customField1",
//                                                                                       @"customKey2" : @"customField2"}];
//    
//    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
//        if (error != nil) {
//            XCTFail(@"Expectation failed: %@", error);
//            return;
//        }
//        
//        XCTAssert([card.identifier length] > 0);
//        XCTAssert([self.utils checkCard:card isEqualToCreateCardRequest:request]);
//        
//        [ex fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test003_SearchCards {
//    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Search should return 1 card which is equal to created card"];
//    
//    NSUInteger numberOfRequests = 2;
//    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
//    
//    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
//    
//    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
//        if (error != nil) {
//            XCTFail(@"Expectation failed: %@", error);
//            return;
//        }
//        
//        VSSSearchCardsCriteria *searchCardsCriteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeApplication identityType:card.identityType identities:@[card.identity]];
//        
//        sleep(3);
//        [self.client searchCardsUsingCriteria:searchCardsCriteria completion:^(NSArray<VSSCard *>* cards, NSError *error) {
//            if (error != nil) {
//                XCTFail(@"Expectation failed: %@", error);
//                return;
//            }
//            
//            XCTAssert([cards count] == 1);
//            XCTAssert([self.utils checkCard:cards[0] isEqualToCard:card]);
//            
//            [ex fulfill];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test004_GetCard {
//    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Get card request should return 1 card which is equal to created card"];
//    
//    NSUInteger numberOfRequests = 2;
//    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
//    
//    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
//    
//    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
//        if (error != nil) {
//            XCTFail(@"Expectation failed: %@", error);
//            return;
//        }
//        
//        sleep(3);
//        [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
//            if (error != nil) {
//                XCTFail(@"Expectation failed: %@", error);
//                return;
//            }
//            
//            XCTAssert(foundCard != nil);
//            XCTAssert([foundCard.identifier isEqualToString:card.identifier]);
//            XCTAssert([self.utils checkCard:foundCard isEqualToCreateCardRequest:request]);
//            
//            [ex fulfill];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test005_RevokeCard {
//    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created. Virgil card should be revoked"];
//    
//    NSUInteger numberOfRequests = 3;
//    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
//    
//    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
//    
//    [self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
//        if (error != nil) {
//            XCTFail(@"Expectation failed: %@", error);
//            return;
//        }
//        
//        VSSRevokeCardRequest *revokeRequest = [self.utils instantiateRevokeCardForCard:card];
//        
//        sleep(3);
//        [self.client revokeCardWithRequest:revokeRequest completion:^(NSError *error) {
//            if (error != nil) {
//                XCTFail(@"Expectation failed: %@", error);
//                return;
//            }
//            
//            [self.client getCardWithId:card.identifier completion:^(VSSCard *foundCard, NSError *error) {
//                XCTAssert(foundCard == nil);
//                
//                XCTAssert(error != nil);
//                XCTAssert(error.code == 404);
//                
//                [ex fulfill];
//            }];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}

@end
