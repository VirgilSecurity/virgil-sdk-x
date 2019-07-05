//
// Copyright (C) 2015-2019 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCrypto;

#if TARGET_OS_IOS
#import "VirgilSDK_AppTests_iOS-Swift.h"
#elif TARGET_OS_TV
#import "VirgilSDK_AppTests_tvOS-Swift.h"
#elif TARGET_OS_OSX
#import "VirgilSDK_macOS_Tests-Swift.h"
#endif

@interface VSK001_ClientTests : XCTestCase

@property (nonatomic) TestUtils *utils;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSSKeyknoxClient *keyknoxClient;

@end

@implementation VSK001_ClientTests

- (void)setUp {
    [super setUp];
    
    self.utils = [TestUtils readFromBundle];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:NO error:nil];
    
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    
    self.keyknoxClient = [[VSSKeyknoxClient alloc] initWithAccessTokenProvider:[self.utils getGeneratorJwtProviderWithIdentity:identity] serviceUrl:self.utils.config.ServiceURL];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test01_KTC1_pushValue {
    NSData *encryptedData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *meta =  [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    VSSEncryptedKeyknoxValue *response = [self.keyknoxClient pushValueWithMeta:meta value:encryptedData previousHash:nil error:&error];
    XCTAssert(response != nil && error == nil);

    XCTAssert([response.meta isEqualToData:meta]);
    XCTAssert([response.value isEqualToData:encryptedData]);
    XCTAssert([response.version isEqualToString:@"1.0"]);
    XCTAssert(response.keyknoxHash.length > 0);

    VSSEncryptedKeyknoxValue *response2 = [self.keyknoxClient pullValueAndReturnError:&error];
    XCTAssert(response != nil && error == nil);

    XCTAssert([response2.meta isEqualToData:meta]);
    XCTAssert([response2.value isEqualToData:encryptedData]);
    XCTAssert([response2.version isEqualToString:@"1.0"]);
    XCTAssert([response2.keyknoxHash isEqualToData:response.keyknoxHash]);
}

- (void)test02_KTC2_updateData {
    NSData *encryptedData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *meta =  [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    VSSEncryptedKeyknoxValue *response = [self.keyknoxClient pushValueWithMeta:meta value:encryptedData previousHash:nil error:&error];
    XCTAssert(response != nil && error == nil);
    
    NSData *encryptedData2 = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *meta2 = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSEncryptedKeyknoxValue *response2 = [self.keyknoxClient pushValueWithMeta:meta2 value:encryptedData2 previousHash:response.keyknoxHash error:&error];
    XCTAssert(response2 != nil && error == nil);
    
    XCTAssert([response2.meta isEqualToData:meta2]);
    XCTAssert([response2.value isEqualToData:encryptedData2]);
    XCTAssert([response2.version isEqualToString:@"2.0"]);
    XCTAssert(response2.keyknoxHash.length > 0);
}

- (void)test03_KTC3_pullEmpty {
    NSError *error;
    VSSEncryptedKeyknoxValue *response = [self.keyknoxClient pullValueAndReturnError:&error];
    XCTAssert(response != nil && error == nil);
    
    XCTAssert(response.value.length == 0);
    XCTAssert(response.meta.length == 0);
    XCTAssert([response.version isEqualToString:@"1.0"]);
}

- (void)test04_KTC4_resetValue {
    NSError *error;
    
    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *someMeta = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSEncryptedKeyknoxValue *response = [self.keyknoxClient pushValueWithMeta:someMeta value:someData previousHash:nil error:&error];
    XCTAssert(response != nil && error == nil);
    
    VSSDecryptedKeyknoxValue *response2 = [self.keyknoxClient resetValueAndReturnError:&error];
    XCTAssert(response2 != nil && error == nil);
    
    XCTAssert(response2.value.length == 0);
    XCTAssert(response2.meta.length == 0);
    XCTAssert([response2.version isEqualToString:@"2.0"]);
}

- (void)test05_KTC5_resetEmptyValue {
    NSError *error;
    
    VSSDecryptedKeyknoxValue *response = [self.keyknoxClient resetValueAndReturnError:&error];
    XCTAssert(response != nil && error == nil);
    
    XCTAssert(response.value.length == 0);
    XCTAssert(response.meta.length == 0);
    XCTAssert([response.version isEqualToString:@"1.0"]);
}

@end
