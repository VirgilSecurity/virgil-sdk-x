//
//  VK001_KeysClientTests.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "BridgingHeader.h"
#import "VSSRequestSigner.h"
#import "VSSPublicKeyPrivate.h"

#import "VSSPrivateKeyPrivate.h"
#import "VSSCardModel.h"
#import "VSSCrypto.h"

/// Virgil Application Token for testing applications
//static NSString *const kApplicationToken = <#NSString: Application Access Token#>;
//static NSString *const kApplicationPublicKey = <# NSString: Application Public Key #>;
//static NSString *const kApplicationPrivateKey = <# NSString: Application Private Key #>;
//static NSString *const kApplicationId = <#NSString: Application Id#>;



/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSRequestSigner *requestSigner;

@property (nonatomic, strong) VSSKeyPair *keyPair;
@property (nonatomic, strong) VSSPublicKey *publicKey;

@property (nonatomic, strong) NSString *validationToken;

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
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created unconfirmed."];

    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    VSSCrypto *crypto = [[VSSCrypto alloc] init];
    VSSClient *client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken];
    
    VSSKeyPair *keyPair = [crypto generateKey];
    
    NSData *publicKey = [crypto exportPublicKey:keyPair.publicKey];
    VSSCardModel *cardModel = [VSSCardModel createWithIdentity:@"test" identityType:@"test" publicKey:publicKey];
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:crypto];
    
    NSData *privateAppKeyData = [kApplicationPrivateKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *appIdData = [kApplicationId dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSPrivateKey *appPrivateKey = [[VSSPrivateKey alloc] initWithKey:privateAppKeyData identifier:appIdData];
    
    NSError *error;
    [signer applicationSignRequest:cardModel withPrivateKey:keyPair.privateKey error:&error];
    [signer authoritySignRequest:cardModel appId:kApplicationId withPrivateKey:appPrivateKey error:&error];
    
    [client createCardWithModel:cardModel completion:^(VSSCardModel *card, NSError *error) {
        if (error == nil)
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
