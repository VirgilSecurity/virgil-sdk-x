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
#import "Mailinator.h"
#import "MailinatorConfig.h"
#import "MEmailMetadata.h"
#import "MPart.h"
#import "MEmail.h"

/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 8.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSTestsUtils *utils;
@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) Mailinator *mailinator;
@property (nonatomic) NSRegularExpression *regexp;

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
    
    self.regexp = [NSRegularExpression regularExpressionWithPattern:@"Your confirmation code is.+([A-Z0-9]{6})" options:NSRegularExpressionCaseInsensitive error:nil];
    self.mailinator = [[Mailinator alloc] initWithApplicationToken:self.consts.mailinatorToken serviceUrl:[[NSURL alloc] initWithString:@"https://api.mailinator.com/api/"]];
}

- (void)tearDown {
    self.client = nil;
    self.crypto = nil;
    self.consts = nil;
    self.mailinator = nil;
    self.regexp = nil;
    self.utils = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testC01_CreateCard {
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

- (void)testC02_CreateCardWithData {
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

- (void)testC03_SearchCards {
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

- (void)testC04_GetCard {
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

- (void)testC05_RevokeCard {
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

- (void)testI01_VerifyEmail {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Verification code should be sent to email"];
    
    NSUInteger numberOfRequests = 3;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    NSString *identity = [self.utils generateEmail];
    
    [self.client verifyIdentity:identity identityType:@"email" extraFields:nil completion:^(NSString *actionId, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(actionId.length != 0);
        
        sleep(3);
        
        NSString *identityShort = [identity substringToIndex:[identity rangeOfString:@"@"].location];
        [self.mailinator getInbox:identityShort completionHandler:^(NSArray<MEmailMetadata *> *metadataList, NSError * error) {
            XCTAssert(error == nil);
            XCTAssert(metadataList != nil);
            XCTAssert(metadataList.count == 1);
            
            [self.mailinator getEmail:metadataList[0].mid completionHandler:^(MEmail *email, NSError *error) {
                XCTAssert(error == nil);
                XCTAssert(email != nil);
                
                MPart *bodyPart = (MPart *)email.parts[0];
                
                NSTextCheckingResult *matchResult = [self.regexp firstMatchInString:bodyPart.body options:NSMatchingReportCompletion range:NSMakeRange(0, bodyPart.body.length)];
                
                XCTAssert(matchResult != nil);
                XCTAssert(matchResult.range.location != NSNotFound);
                
                NSString *match = [bodyPart.body substringWithRange:matchResult.range];
                
                NSString *code = [match substringFromIndex:match.length - 6];
                
                XCTAssert(code.length == 6);
                
                [ex fulfill];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)testI02_ConfirmEmail {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Verification code should be sent to email. Validation token should be obtained"];
    
    NSUInteger numberOfRequests = 4;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    NSString *identity = [self.utils generateEmail];
    
    [self.client verifyIdentity:identity identityType:@"email" extraFields:nil completion:^(NSString *actionId, NSError *error) {
        sleep(3);
        
        NSString *identityShort = [identity substringToIndex:[identity rangeOfString:@"@"].location];
        [self.mailinator getInbox:identityShort completionHandler:^(NSArray<MEmailMetadata *> *metadataList, NSError * error) {
            [self.mailinator getEmail:metadataList[0].mid completionHandler:^(MEmail *email, NSError *error) {
                MPart *bodyPart = (MPart *)email.parts[0];
                
                NSTextCheckingResult *matchResult = [self.regexp firstMatchInString:bodyPart.body options:NSMatchingReportCompletion range:NSMakeRange(0, bodyPart.body.length)];
                
                NSString *match = [bodyPart.body substringWithRange:matchResult.range];
                
                NSString *code = [match substringFromIndex:match.length - 6];
                
                [self.client confirmIdentityWithActionId:actionId confirmationCode:code timeToLive:3600 countToLive:12 completion:^(VSSConfirmIdentityResponse *response, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(response != nil);
                    XCTAssert([response.identityType isEqualToString:@"email"]);
                    XCTAssert([response.identityValue isEqualToString:identity]);
                    XCTAssert(response.validationToken.length != 0);
                    
                    [ex fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)testI03_ValidateEmail {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Verification code should be sent to email. Validation token should be obtained. Confirmation should pass"];
    
    NSUInteger numberOfRequests = 5;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    NSString *identity = [self.utils generateEmail];
    
    [self.client verifyIdentity:identity identityType:@"email" extraFields:nil completion:^(NSString *actionId, NSError *error) {
        sleep(3);
        
        NSString *identityShort = [identity substringToIndex:[identity rangeOfString:@"@"].location];
        [self.mailinator getInbox:identityShort completionHandler:^(NSArray<MEmailMetadata *> *metadataList, NSError * error) {
            [self.mailinator getEmail:metadataList[0].mid completionHandler:^(MEmail *email, NSError *error) {
                MPart *bodyPart = (MPart *)email.parts[0];
                
                NSTextCheckingResult *matchResult = [self.regexp firstMatchInString:bodyPart.body options:NSMatchingReportCompletion range:NSMakeRange(0, bodyPart.body.length)];
                
                NSString *match = [bodyPart.body substringWithRange:matchResult.range];
                
                NSString *code = [match substringFromIndex:match.length - 6];
                
                [self.client confirmIdentityWithActionId:actionId confirmationCode:code timeToLive:3600 countToLive:12 completion:^(VSSConfirmIdentityResponse *response, NSError *error) {
                    [self.client validateIdentity:identity identityType:@"email" validationToken:response.validationToken completion:^(NSError *error) {
                        XCTAssert(error == nil);
                        
                        [ex fulfill];
                    }];
                }];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
