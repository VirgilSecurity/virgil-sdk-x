//
//  VSS005_CompatibilityTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"

@interface VSS005_CompatibilityTests : XCTestCase

@property (nonatomic) VSSTestsUtils * __nonnull utils;
@property (nonatomic) VSSCrypto * __nonnull crypto;
@property (nonatomic) NSDictionary * __nonnull testDict;

@end

@implementation VSS005_CompatibilityTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.crypto = [[VSSCrypto alloc] init];
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:self.crypto consts:[[VSSTestsConst alloc] init]];
    
    NSURL *testFileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"sdk_compatibility_data" withExtension:@"json"];
    NSData *testFileData = [[NSData alloc] initWithContentsOfURL:testFileURL];
    
    self.testDict = [NSJSONSerialization JSONObjectWithData:testFileData options:0 error:nil];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_CheckNumberOfTestsInJSON {
    XCTAssert([self.testDict count] == 9);
}

- (void)test002_DecryptFromSingleRecipient_ShouldDecrypt {
    NSDictionary *dict = self.testDict[@"encrypt_single_recipient"];
    
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:privateKeyData withPassword:nil];
    
    NSString *originalDataStr = dict[@"original_data"];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherDataStr options:0];
    
    NSError *error;
    
    NSData *decryptedData = [self.crypto decryptData:cipherData withPrivateKey:privateKey error:&error];
    NSString *decryptedDataStr = [decryptedData base64EncodedStringWithOptions:0];
    
    XCTAssert(error == nil);
    XCTAssert([decryptedDataStr isEqualToString:originalDataStr]);
}

- (void)test003_DecryptFromMultipleRecipients_ShouldDecypt {
    NSDictionary *dict = self.testDict[@"encrypt_multiple_recipients"];
    
    NSMutableArray<VSSPrivateKey *> *privateKeys = [[NSMutableArray<VSSPrivateKey *> alloc] init];
    
    for (NSString *privateKeyStr in (NSArray *)dict[@"private_keys"]) {
        NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
        
        VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:privateKeyData withPassword:nil];
        
        [privateKeys addObject:privateKey];
    }
    
    XCTAssert([privateKeys count] > 0);
    
    NSString *originalDataStr = dict[@"original_data"];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherDataStr options:0];
    
    for (VSSPrivateKey * privateKey in privateKeys) {
        NSError *error;
        NSData *decryptedData = [self.crypto decryptData:cipherData withPrivateKey:privateKey error:&error];
        NSString *decryptedDataStr = [decryptedData base64EncodedStringWithOptions:0];
        
        XCTAssert(error == nil);
        XCTAssert([decryptedDataStr isEqualToString:originalDataStr]);
    }
}

- (void)test004_DecryptThenVerifySingleRecipient_ShouldDecryptThenVerify {
    NSDictionary *dict = self.testDict[@"sign_then_encrypt_single_recipient"];
    
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:privateKeyData withPassword:nil];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherDataStr options:0];
    
    NSError *error;
    VSSPublicKey *publicKey = [self.crypto extractPublicKeyFromPrivateKey:privateKey];
    NSData *decryptedData = [self.crypto decryptThenVerifyData:cipherData withPrivateKey:privateKey usingSignerPublicKey:publicKey error:&error];
    
    XCTAssert(error == nil);
    
    NSString *decryptedStr = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    NSString *originalStr = [[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding];
    
    XCTAssert([originalStr isEqualToString:decryptedStr]);
}

- (void)test005_DecryptThenVerifyMultipleRecipients_ShouldDecryptThenVerify {
    NSDictionary *dict = self.testDict[@"sign_then_encrypt_multiple_recipients"];

    NSMutableArray<VSSPrivateKey *> *privateKeys = [[NSMutableArray<VSSPrivateKey *> alloc] init];
    
    for (NSString *privateKeyStr in (NSArray *)dict[@"private_keys"]) {
        NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
        
        VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:privateKeyData withPassword:nil];
        
        [privateKeys addObject:privateKey];
    }
    
    XCTAssert([privateKeys count] > 0);
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherDataStr options:0];
    
    NSString *originalDataStr = dict[@"original_data"];
    
    VSSPublicKey *signerPublicKey = [self.crypto extractPublicKeyFromPrivateKey:privateKeys[0]];
    
    for (VSSPrivateKey * privateKey in privateKeys) {
        NSError *error;
        NSData *decryptedData = [self.crypto decryptThenVerifyData:cipherData withPrivateKey:privateKey usingSignerPublicKey:signerPublicKey error:&error];
        NSString *decryptedDataStr = [decryptedData base64EncodedStringWithOptions:0];
        
        XCTAssert(error == nil);
        XCTAssert([decryptedDataStr isEqualToString:originalDataStr]);
    }
}

- (void)test006_GenerateSignature_ShouldBeEqual {
    NSDictionary *dict = self.testDict[@"generate_signature"];
    
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:privateKeyData withPassword:nil];
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    
    NSError *error;
    NSData *signature = [self.crypto generateSignatureForData:originalData withPrivateKey:privateKey error:&error];
    NSString *signatureStr = [signature base64EncodedStringWithOptions:0];
    
    NSString *originalSignatureStr = dict[@"signature"];
    
    XCTAssert(error == nil);
    XCTAssert([originalSignatureStr isEqualToString:signatureStr]);
}

- (void)test007_ExportSignableData_ShouldBeEqual {
    NSDictionary *dict = self.testDict[@"export_signable_request"];
    
    NSString *exportedRequest = dict[@"exported_request"];
    
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithData:exportedRequest];
    
    XCTAssert(request != nil);
    
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:request.snapshot];
    
    VSSPublicKey *creatorPublicKey = [self.crypto importPublicKeyFromData:request.snapshotModel.publicKeyData];
    
    NSError *error;
    XCTAssert([self.crypto verifyData:fingerprint.value withSignature:request.signatures[fingerprint.hexValue] usingSignerPublicKey:creatorPublicKey error:&error]);
    XCTAssert(error == nil);
}
    
- (void)test008_DecryptThenVerifyMultipleSigners_ShouldDecryptThenVerify {
    NSDictionary *dict = self.testDict[@"sign_then_encrypt_multiple_signers"];
    
    NSMutableArray<VSSPublicKey *> *publicKeys = [[NSMutableArray<VSSPublicKey *> alloc] init];
    
    for (NSString *publicKeyStr in (NSArray *)dict[@"public_keys"]) {
        NSData *publicKeyData = [[NSData alloc] initWithBase64EncodedString:publicKeyStr options:0];
        
        VSSPublicKey *publicKey = [self.crypto importPublicKeyFromData:publicKeyData];
        
        [publicKeys addObject:publicKey];
    }
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherDataStr options:0];
    
    NSString *originalDataStr = dict[@"original_data"];
    
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:privateKeyData withPassword:nil];
    
    NSError *error;
    NSData *decryptedData = [self.crypto decryptThenVerifyData:cipherData withPrivateKey:privateKey usingOneOfSignersPublicKeys:publicKeys error:&error];
    NSString *decryptedDataStr = [decryptedData base64EncodedStringWithOptions:0];
    
    XCTAssert(error == nil);
    XCTAssert([decryptedDataStr isEqualToString:originalDataStr]);
}

- (void)test009_ExportPublishedGlobalCard_ShouldBeEqual {
    NSDictionary *dict = self.testDict[@"export_published_global_virgil_card"];
    
    NSString *id = dict[@"card_id"];
    NSString *exportedCard = dict[@"exported_card"];
    
    VSSCard *card = [[VSSCard alloc] initWithData:exportedCard];
    XCTAssert([card.identifier isEqualToString:id]);
}

- (void)test010_ExportUnpublishedLocalCard_ShouldBeEqual {
    NSDictionary *dict = self.testDict[@"export_unpublished_local_virgil_card"];
    
    NSString *id = dict[@"card_id"];
    NSString *exportedRequest = dict[@"exported_card"];
    
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithData:exportedRequest];
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:request.snapshot];
    
    XCTAssert([fingerprint.hexValue isEqualToString:id]);
}

@end
