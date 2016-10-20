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

    NSData *decryptedData = [self.crypto decryptData:encryptedData withPrivateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    XCTAssert([decryptedData isEqualToData:data]);
}

- (void)testED002_EncryptRandomData_SingleIncorrectKey_ShouldNotDecrypt {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
    
    NSError *error;
    NSData *encryptedData = [self.crypto encryptData:data forRecipients:@[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData = [self.crypto decryptData:encryptedData withPrivateKey:wrongKeyPair.privateKey error:&error];
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
    
    NSData *decryptedData1 = [self.crypto decryptData:encryptedData withPrivateKey:keyPair1.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    XCTAssert([decryptedData1 isEqualToData:data]);
    
    NSData *decryptedData2 = [self.crypto decryptData:encryptedData withPrivateKey:keyPair2.privateKey error:&error];
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
    [self.crypto encryptStream:inputStreamForEncryption toOutputStream:outputStreamForEncryption forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];

    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecryption = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption = [[NSOutputStream alloc] initToMemory];

    [self.crypto decryptStream:inputStreamForDecryption toOutputStream:outputStreamForDecryption withPrivateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    NSData *decryptedData = [outputStreamForDecryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData != nil);
    
    XCTAssert([decryptedData isEqualToData:data]);
}

- (void)testES002_EncryptRandomDataStream_SingleIncorrectKey_ShouldNotDecrypt {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
    
    NSInputStream *inputStreamForEncrypt = [[NSInputStream alloc] initWithData:data];
    NSOutputStream *outputStreamForEncrypt = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncrypt toOutputStream:outputStreamForEncrypt forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncrypt propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecrypt = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecrypt = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecrypt toOutputStream:outputStreamForDecrypt withPrivateKey:wrongKeyPair.privateKey error:&error];
    NSData *decryptedData = [outputStreamForDecrypt propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    XCTAssert([decryptedData length] == 0);
    XCTAssert(error != nil);
}

- (void)testES003_EncryptRandomDataStream_TwoCorrectKeys_ShouldDecrypt {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair1 = [self.crypto generateKeyPair];
    VSSKeyPair *keyPair2 = [self.crypto generateKeyPair];
    
    NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithData:data];
    NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncryption toOutputStream:outputStreamForEncryption forRecipients: @[keyPair1.publicKey, keyPair2.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecryption1 = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption1 = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecryption1 toOutputStream:outputStreamForDecryption1 withPrivateKey:keyPair1.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData1 = [outputStreamForDecryption1 propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData1 != nil);
    
    XCTAssert([decryptedData1 isEqualToData:data]);
    
    NSInputStream *inputStreamForDecryption2 = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption2 = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecryption2 toOutputStream:outputStreamForDecryption2 withPrivateKey:keyPair2.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedData2 = [outputStreamForDecryption2 propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(decryptedData2 != nil);
    
    XCTAssert([decryptedData2 isEqualToData:data]);
}

- (void)testES004_EncryptFileDataStream_SingleCorrectKey_ShouldDecrypt {
    NSURL *testFileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"testData" withExtension:@"txt"];
    NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithURL:testFileURL];

    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    
    NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];
    
    NSError *error;
    [self.crypto encryptStream:inputStreamForEncryption toOutputStream:outputStreamForEncryption forRecipients: @[keyPair.publicKey] error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *encryptedData = [outputStreamForEncryption propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssert(encryptedData != nil);
    
    NSInputStream *inputStreamForDecryption = [[NSInputStream alloc] initWithData:encryptedData];
    NSOutputStream *outputStreamForDecryption = [[NSOutputStream alloc] initToMemory];
    
    [self.crypto decryptStream:inputStreamForDecryption toOutputStream:outputStreamForDecryption withPrivateKey:keyPair.privateKey error:&error];
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
    NSData *signature = [self.crypto generateSignatureForData:data withPrivateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    BOOL isVerified = [self.crypto verifyData:data withSignature:signature usingSignerPublicKey:keyPair.publicKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }

    XCTAssert(isVerified);
}

- (void)testSD002_SignRandomData_IncorrectKeys_ShouldNotValidate {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    VSSKeyPair *wrongKeyPair = [self.crypto generateKeyPair];
    
    NSError *error;
    NSData *signature = [self.crypto generateSignatureForData:data withPrivateKey:keyPair.privateKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    BOOL verified = [self.crypto verifyData:data withSignature:signature usingSignerPublicKey:wrongKeyPair.publicKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    XCTAssert(!verified);
}

- (void)testESD001_SignAndEncryptRandomData_CorrectKeys_ShouldDecryptValidate {
    NSData *data = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    
    VSSKeyPair *senderKeyPair = [self.crypto generateKeyPair];
    VSSKeyPair *receiverKeyPair = [self.crypto generateKeyPair];
    
    NSError *error;
    NSData *signedAndEcnryptedData = [self.crypto signAndEncryptData:data withPrivateKey:senderKeyPair.privateKey forRecipients:@[receiverKeyPair.publicKey] error:&error];
    
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    NSData *decryptedAndVerifiedData = [self.crypto decryptAndVerifyData:signedAndEcnryptedData withPrivateKey:receiverKeyPair.privateKey usingSignerPublicKey:senderKeyPair.publicKey error:&error];
    if (error != nil) {
        XCTFail(@"Expectation failed: %@", error);
        return;
    }
    
    XCTAssert([data isEqualToData:decryptedAndVerifiedData]);
}

@end
