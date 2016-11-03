//
//  VSS005_KeyStorageTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"

@interface VSS005_KeyStorageTests : XCTestCase

@property (nonatomic) VSSCrypto * __nonnull crypto;
@property (nonatomic) VSSKeyStorage * __nonnull storage;
@property (nonatomic) VSSKeyEntry * __nonnull keyEntry;
@property (nonatomic) NSString * __nonnull privateKeyName;

@end

@implementation VSS005_KeyStorageTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.crypto = [[VSSCrypto alloc] init];
    self.storage = [[VSSKeyStorage alloc] init];
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    
    NSData *privateKeyRawData = [self.crypto exportPrivateKey:keyPair.privateKey withPassword:nil];
    NSString *privateKeyName = [[NSUUID UUID] UUIDString];
    
    self.keyEntry = [VSSKeyEntry keyEntryWithName:privateKeyName value:privateKeyRawData];
}

- (void)tearDown {
    [self.storage deleteKeyEntryWithName:self.keyEntry.name error:nil];
    
    [super tearDown];
}

- (void)test001_SaveAndGetKey {
    NSError *error;
    [self.storage storeKeyEntry:self.keyEntry error:&error];
    XCTAssert(error == nil);
    
    VSSKeyEntry *loadedKeyEntry = [self.storage loadKeyEntryWithName:self.keyEntry.name error:&error];
    
    XCTAssert(error == nil);
    XCTAssert(loadedKeyEntry != nil);
    XCTAssert([loadedKeyEntry.name isEqualToString:self.keyEntry.name]);
    XCTAssert([loadedKeyEntry.value isEqualToData:self.keyEntry.value]);
}

@end
