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
static NSString *const kApplicationId = <#NSString: Application Id#>;


/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSRequestSigner *requestSigner;

@end

@implementation VSS001_ClientTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];

    self.client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken];
    self.crypto = [[VSSCrypto alloc] init];
    self.requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
}

- (void)tearDown {
    self.client = nil;
    self.crypto = nil;
    self.requestSigner = nil;
    
    [super tearDown];
}

- (void)test001_CreateCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created."];

    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCardModel *instantiatedCardModel = [self instantiateCardModel];
    
    [self.client createCardWithModel:instantiatedCardModel completion:^(VSSCardModel *card, NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
        
        XCTAssert([card.identifier length] > 0);
        XCTAssert([self checkCard:instantiatedCardModel isEqualToCard:card]);
        
        VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
        [validator addVerifierWithId:kApplicationId publicKey:[[NSData alloc] initWithBase64EncodedString:kApplicationPublicKeyBase64 options:0]];

        BOOL isValid = [validator validateCard:card];

        XCTAssert(isValid);
        
        [ex fulfill];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
    }];
}

@end
