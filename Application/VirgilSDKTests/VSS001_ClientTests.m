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
static NSString *const kApplicationPublicKey = <# NSString: Application Public Key #>;
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
    
    VSSKeyPair *keyPair = [self.crypto generateKey];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = [[NSUUID UUID] UUIDString];
    NSString *identityType = @"test";
    VSSCardModel *cardModel = [VSSCardModel createWithIdentity:identityValue identityType:identityType publicKey:exportedPublicKey];

    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:kApplicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKey:privateAppKeyData password:@"test"];
    
    NSError *error;
    [self.requestSigner applicationSignRequest:cardModel withPrivateKey:keyPair.privateKey error:&error];
    [self.requestSigner authoritySignRequest:cardModel appId:kApplicationId withPrivateKey:appPrivateKey error:&error];
    
    [self.client createCardWithModel:cardModel completion:^(VSSCardModel *card, NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
        
        XCTAssert([card.data.identity isEqualToString:identityValue]);
        XCTAssert([card.data.identityType isEqualToString:identityType]);
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
