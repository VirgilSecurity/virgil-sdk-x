//
//  VSS002_ClientWOTokenTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
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

@interface VSS002_ClientWOTokenTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSTestsUtils *utils;
@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) Mailinator *mailinator;
@property (nonatomic) NSRegularExpression *regexp;

@end

@implementation VSS002_ClientWOTokenTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    
    VSSServiceConfig *config = [VSSServiceConfig defaultServiceConfig];
    self.crypto = [[VSSCrypto alloc] init];
    VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:[[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0] withPassword:self.consts.applicationPrivateKeyPassword];
    VSSPublicKey *publicKey = [self.crypto extractPublicKeyFromPrivateKey:privateKey];
    NSData *publicKeyData = [self.crypto exportPublicKey:publicKey];
    
    XCTAssert([validator addVerifierWithId:self.consts.applicationId publicKeyData:publicKeyData]);
    
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

- (void) testA01_CreateGlobalEmailCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Global Email Virgil Card should be created"];
    
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
                    
                    VSSCreateGlobalCardRequest *request = [self.utils instantiateEmailCreateCardRequestWithIdentity:identity validationToken:response.validationToken keyPair:nil];
                    
                    [self.client createGlobalCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
                        XCTAssert(error == nil);
                        
                        XCTAssert([self.utils checkCard:card isEqualToCreateGlobalCardRequest:request]);
                        
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

- (void) testA02_RevokeGlobalEmailCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Global Email Virgil Card should be created. Global Email Virgil Card should be revoked."];
    
    NSUInteger numberOfRequests = 6;
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
                    
                    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
                    VSSCreateGlobalCardRequest *request = [self.utils instantiateEmailCreateCardRequestWithIdentity:identity validationToken:response.validationToken keyPair:keyPair];
                    
                    [self.client createGlobalCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
                        VSSRevokeGlobalCardRequest *revokeRequest = [self.utils instantiateRevokeGlobalCardForCard:card validationToken:response.validationToken withPrivateKey:keyPair.privateKey];
                        
                        [self.client revokeGlobalCardWithRequest:revokeRequest completion:^(NSError *error) {
                            XCTAssert(error == nil);
                            
                            [ex fulfill];
                        }];
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
