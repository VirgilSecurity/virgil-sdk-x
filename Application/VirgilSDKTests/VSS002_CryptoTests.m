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

@property (nonatomic) VSSCrypto *crypto;

@end

@implementation VSS002_CryptoTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.crypto = [[VSSCrypto alloc] init];
}

- (void)tearDown {
    self.crypto = nil;
    
    [super tearDown];
}

#pragma mark - Encryption tests

- (void)testE001_EncryptRandomData_SingleCorrectKey_ShouldDecrypt {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];

    VSSKeyPair *keyPair = [self.crypto generateKeyPair];

    NSError *error;
    NSData *encryptedData = [self.crypto encryptData:data forRecipients:@[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    NSData *decryptedData = [self.crypto decryptData:encryptedData privateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    XCTAssert([decryptedData isEqualToData:data]);
}

- (void)testE002_EncryptRandomData_SingleIncorrect_ShouldNotDecrypt {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
    
    NSError *error;
    NSData *encryptedData = [self.crypto encryptData:data forRecipients:@[wrongKeyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData = [self.crypto decryptData:encryptedData privateKey:keyPair.privateKey error:&error];
    XCTAssert(decryptedData == nil);
    XCTAssert(error != nil);
}

- (void)testE003_EncryptRandomDataStream_SingleCorrectKey_ShouldDecrypt {
    NSMutableData *mutableData = [[NSMutableData alloc] initWithCapacity:2 * 1024 * 1024];
    
    for (int i = 0; i < 40; i++) {
        [mutableData appendData:[[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSData *data = mutableData;
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    
    NSInputStream *inputStreamForEncrypt = [[NSInputStream alloc] initWithData:data];
    NSOutputStream *outputStreamForEncrypt = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncrypt outputStream:outputStreamForEncrypt forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncrypt propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecrypt = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecrypt = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecrypt outputStream:outputStreamForDecrypt privateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData = [outputStreamForDecrypt propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData != nil);
    
    XCTAssert([decryptedData isEqualToData:data]);
}

- (void)testE004_EncryptRandomDataStream_KeysDoesntMatch_ShouldNotDecrypt {
    NSMutableData *mutableData = [[NSMutableData alloc] initWithCapacity:2 * 1024 * 1024];
    
    for (int i = 0; i < 40; i++) {
        [mutableData appendData:[[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSData *data = mutableData;
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
    
    NSInputStream *inputStreamForEncrypt = [[NSInputStream alloc] initWithData:data];
    NSOutputStream *outputStreamForEncrypt = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncrypt outputStream:outputStreamForEncrypt forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncrypt propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecrypt = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecrypt = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecrypt outputStream:outputStreamForDecrypt privateKey:wrongKeyPair.privateKey error:&error];
    NSData *decryptedData = [outputStreamForDecrypt propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    XCTAssert([decryptedData length] == 0);
    XCTAssert(error != nil);
}

#pragma mark - Signature tests

- (void)testS001_SignRandomData_CorrectKeys_ShouldValidate {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];

    VSSKeyPair *keyPair = [self.crypto generateKeyPair];

    NSError *error;
    NSData *signature = [self.crypto signData:data privateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    BOOL verified = [self.crypto verifyData:data signature:signature signerPublicKey:keyPair.publicKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    XCTAssert(verified);
}

- (void)testS002_SignRandomData_KeysDoesntMatch_ShouldNotValidate {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
    
    NSError *error;
    NSData *signature = [self.crypto signData:data privateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    BOOL verified = [self.crypto verifyData:data signature:signature signerPublicKey:wrongKeyPair.publicKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    XCTAssert(!verified);
}

@end
