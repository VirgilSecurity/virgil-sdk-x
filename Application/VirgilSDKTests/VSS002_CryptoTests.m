//
//  VSS002_CryptoTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSClient.h"
#import "VSSCrypto.h"

@interface VSS002_CryptoTests: XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;

@end

@implementation VSS002_CryptoTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
//    self.client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken];
    self.crypto = [[VSSCrypto alloc] init];
    self.continueAfterFailure = NO;
}

- (void)tearDown {
    self.client = nil;
    self.crypto = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_test {
    
}

@end
