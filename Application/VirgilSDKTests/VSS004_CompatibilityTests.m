//
//  VSS004_CompatibilityTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"
#import "VSSCrypto.h"

@interface VSS004_CompatibilityTests : XCTestCase

@property (nonatomic) VSSTestsUtils * __nonnull utils;
@property (nonatomic) VSSCrypto * __nonnull crypto;

- (void)testWithName:(NSString * __nonnull)name dict:(NSDictionary * __nonnull)dict;

- (void)encryptSingleRecipientTestWithDict:(NSDictionary * __nonnull)dict;
- (void)encryptMultipleRecipientsWithDict:(NSDictionary * __nonnull)dict;
- (void)generateSignatureWithDict:(NSDictionary * __nonnull)dict;
- (void)exportSignableRequestWithDict:(NSDictionary * __nonnull)dict;

@end

@implementation VSS004_CompatibilityTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.crypto = [[VSSCrypto alloc] init];
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:self.crypto];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_TestUsingCompatibilityFile {
    NSURL *testFileURL = [[NSBundle mainBundle] URLForResource:@"sdk_compatibility_data" withExtension:@"json"];
    NSData *testFileData = [[NSData alloc] initWithContentsOfURL:testFileURL];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:testFileData options:0 error:nil];
    
    XCTAssert([dict count] != 0);
    
    for (NSString *key in dict.allKeys) {
        [self testWithName:key dict:dict[key]];
    }
}

- (void)testWithName:(NSString *)name dict:(NSDictionary *)dict {
    if ([name isEqualToString:@"encrypt_single_recipient"]) {
        [self encryptSingleRecipientTestWithDict:dict];
    }
    else if ([name isEqualToString:@"encrypt_multiple_recipients"]) {
        [self encryptMultipleRecipientsWithDict:dict];
    }
    else if ([name isEqualToString:@"sign_then_encrypt_single_recipient"]) {
        
    }
    else if ([name isEqualToString:@"sign_then_encrypt_multiple_recipients"]) {
        
    }
    else if ([name isEqualToString:@"generate_signature"]) {
        [self generateSignatureWithDict:dict];
    }
    else if ([name isEqualToString:@"export_signable_request"]) {
        [self exportSignableRequestWithDict:dict];
    }
    else {
        XCTFail("Unknwon test name: %@", name);
    }
}

- (void)encryptSingleRecipientTestWithDict:(NSDictionary *)dict {
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
    VSSPublicKey *publicKey = [self.crypto extractPublicKeyFromPrivateKey:privateKey];
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    
    NSError *error;
    NSData *encryptedData = [self.crypto encryptData:originalData forRecipients:@[publicKey] error:&error];
    NSString *encryptedDataStr = [encryptedData base64EncodedStringWithOptions:0];
    
    XCTAssert(error == nil);
    XCTAssert([encryptedDataStr isEqualToString:cipherDataStr]);
}

- (void)encryptMultipleRecipientsWithDict:(NSDictionary *)dict {
    NSMutableArray<VSSPublicKey *> *publicKeys = [[NSMutableArray<VSSPublicKey *> alloc] init];
    
    for (NSString *privateKeyStr in (NSArray *)dict[@"private_keys"]) {
        NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
        
        VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
        VSSPublicKey *publicKey = [self.crypto extractPublicKeyFromPrivateKey:privateKey];
        
        [publicKeys addObject:publicKey];
    }
    
    XCTAssert([publicKeys count] > 0);
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    
    NSError *error;
    NSData *encryptedData = [self.crypto encryptData:originalData forRecipients:publicKeys error:&error];
    NSString *encryptedDataStr = [encryptedData base64EncodedStringWithOptions:0];
    
    XCTAssert(error == nil);
    XCTAssert([encryptedDataStr isEqualToString:cipherDataStr]);
}

- (void)signThenEncryptSingleRecipientWithDict:(NSDictionary *)dict {
    NSMutableArray<VSSPrivateKey *> *privateKeys = [[NSMutableArray<VSSPrivateKey *> alloc] init];
    
    for (NSString *privateKeyStr in (NSArray *)dict[@"private_keys"]) {
        NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
        
        VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
        
        [privateKeys addObject:privateKey];
    }

    
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    
    XCTFail(@"Not implemented");
}

- (void)signThenEncryptMultipleRecipientWithDict:(NSDictionary *)dict {
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    
    NSString *cipherDataStr = dict[@"cipher_data"];
    
    XCTFail(@"Not implemented");
}

- (void)generateSignatureWithDict:(NSDictionary *)dict {
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
    
    NSString *originalDataStr = dict[@"original_data"];
    NSData *originalData = [[NSData alloc] initWithBase64EncodedString:originalDataStr options:0];
    
    NSError *error;
    NSData *signature = [self.crypto signatureForData:originalData privateKey:privateKey error:&error];
    NSString *signatureStr = [signature base64EncodedStringWithOptions:0];
    
    NSString *originalSignatureStr = dict[@"signature"];
    
    XCTAssert(error == nil);
    XCTAssert([originalSignatureStr isEqualToString:signatureStr]);
}

- (void)exportSignableRequestWithDict:(NSDictionary *)dict {
    NSString *privateKeyStr = dict[@"private_key"];
    NSData *privateKeyData = [[NSData alloc] initWithBase64EncodedString:privateKeyStr options:0];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKey:privateKeyData password:nil];
    
    NSString *exportedRequestStr = dict[@"exported_request"];
}

@end
