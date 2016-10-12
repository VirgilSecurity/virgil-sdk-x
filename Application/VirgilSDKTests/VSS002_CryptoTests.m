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

- (void)testED001_EncryptRandomData_SingleCorrectKey_ShouldDecrypt {
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

- (void)testED002_EncryptRandomData_SingleIncorrect_ShouldNotDecrypt {
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

- (void)testED003_EncryptRandomData_TwoCorrectKeys_ShouldDecrypt {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair1 = [self.crypto generateKeyPair];
    VSSKeyPair *keyPair2 = [self.crypto generateKeyPair];
    
    NSError *error;
    NSData *encryptedData = [self.crypto encryptData:data forRecipients:@[keyPair1.publicKey, keyPair2.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData1 = [self.crypto decryptData:encryptedData privateKey:keyPair1.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    XCTAssert([decryptedData1 isEqualToData:data]);
    
    NSData *decryptedData2 = [self.crypto decryptData:encryptedData privateKey:keyPair2.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    XCTAssert([decryptedData2 isEqualToData:data]);
}

- (void)testES001_EncryptRandomDataStream_SingleCorrectKey_ShouldDecrypt {    
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    
    NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithData:data];
    NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncryption outputStream:outputStreamForEncryption forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecryption = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption = [[NSOutputStream alloc] initToMemory];

    [self.crypto decryptStream:inputStreamForDecryption outputStream:outputStreamForDecryption privateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    NSData *decryptedData = [outputStreamForDecryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData != nil);
    
    XCTAssert([decryptedData isEqualToData:data]);
}

- (void)testES002_EncryptRandomDataStream_KeysDoesntMatch_ShouldNotDecrypt {
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

- (void)testES003_EncryptRandomDataStream_TwoCorrectKeys_ShouldDecrypt {
    NSMutableData *mutableData = [[NSMutableData alloc] initWithCapacity:2 * 1024 * 1024];
    
    for (int i = 0; i < 40; i++) {
        [mutableData appendData:[[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSData *data = mutableData;
    
    VSSKeyPair *keyPair1 = [self.crypto generateKeyPair];
    VSSKeyPair *keyPair2 = [self.crypto generateKeyPair];
    
    NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithData:data];
    NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncryption outputStream:outputStreamForEncryption forRecipients: @[keyPair1.publicKey, keyPair2.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecryption1 = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption1 = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecryption1 outputStream:outputStreamForDecryption1 privateKey:keyPair1.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData1 = [outputStreamForDecryption1 propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData1 != nil);
    
    XCTAssert([decryptedData1 isEqualToData:data]);
    
    NSInputStream *inputStreamForDecryption2 = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption2 = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecryption2 outputStream:outputStreamForDecryption2 privateKey:keyPair2.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData2 = [outputStreamForDecryption2 propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData2 != nil);
    
    XCTAssert([decryptedData2 isEqualToData:data]);
}

- (void)testES004_EncryptFileDataStream_SingleCorrectKey_ShouldDecrypt {
    NSURL *testFileURL = [[NSBundle mainBundle] URLForResource:@"testData" withExtension:@"txt"];
    NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithURL:testFileURL];

    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    
    NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncryption outputStream:outputStreamForEncryption forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecryption = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecryption outputStream:outputStreamForDecryption privateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData = [outputStreamForDecryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData != nil);
    
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    XCTAssert([decryptedString isEqualToString:@"Hello, Bob!"]);
}

#pragma mark - Signature tests

- (void)testSD001_SignRandomData_CorrectKeys_ShouldValidate {
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

- (void)testSD002_SignRandomData_KeysDoesntMatch_ShouldNotValidate {
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

//- (void)testSS001_SignRandomDataStream_CorrectKeys_ShouldValidate {
//    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
//    
//    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
//    
//    NSError *error;
//    NSData *signature = [self.crypto signData:data privateKey:keyPair.privateKey error:&error];
//    if (error != nil) {
//        XCTFail(@"Expectation failed: %@", error);
//        return;
//    }
//    
//    BOOL verified = [self.crypto verifyData:data signature:signature signerPublicKey:keyPair.publicKey error:&error];
//    if (error != nil) {
//        XCTFail(@"Expectation failed: %@", error);
//        return;
//    }
//    
//    XCTAssert(verified);
//}
//
//- (void)testSS002_SignRandomDataStream_KeysDoesntMatch_ShouldNotValidate {
//    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
//    
//    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
//    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
//    
//    NSError *error;
//    NSData *signature = [self.crypto signData:data privateKey:keyPair.privateKey error:&error];
//    if (error != nil) {
//        XCTFail(@"Expectation failed: %@", error);
//        return;
//    }
//    
//    BOOL verified = [self.crypto verifyData:data signature:signature signerPublicKey:wrongKeyPair.publicKey error:&error];
//    if (error != nil) {
//        XCTFail(@"Expectation failed: %@", error);
//        return;
//    }
//    
//    XCTAssert(!verified);
//}

@end
