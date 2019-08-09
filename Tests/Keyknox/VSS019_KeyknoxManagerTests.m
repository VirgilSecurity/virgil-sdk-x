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

#import "VSSTestBase.h"

static const NSTimeInterval timeout = 20.;

@interface VSS002_KeyknoxManagerTests : VSSTestBase

@property (nonatomic) VSSKeyknoxManager *keyknoxManager;
@property (nonatomic) uint32_t numberOfKeys;
@property (nonatomic) VSSKeyknoxClient *keyknoxClient;
@property (nonatomic) VSMVirgilKeyPair *keyPair;
@property (nonatomic) NSString *identity;

@end

@implementation VSS002_KeyknoxManagerTests

- (void)setUp {
    [super setUp];

    NSString *identity = [[NSUUID alloc] init].UUIDString;

    self.identity = identity;

    self.keyknoxClient = [self.utils setupKeyknoxClientWithIdentity:identity];

    self.keyknoxManager = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient];

    self.keyPair = [self.crypto generateKeyPairAndReturnError:nil];
    XCTAssert(self.keyPair != nil);
    
    self.numberOfKeys = 50;
}

- (void)tearDown {
    [super tearDown];
}

- (void)test01_KTC6_pushValue {
    XCTestExpectation *ex = [self expectationWithDescription:@""];
    
    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];

    [self.keyknoxManager pushValueWithIdentities:@[self.identity]
                                           root1:VSSCloudKeyStorage.root1
                                           root2:VSSCloudKeyStorage.root2
                                             key:VSSCloudKeyStorage.key
                                            data:someData
                                    previousHash:nil
                                      publicKeys:@[self.keyPair.publicKey]
                                      privateKey:self.keyPair.privateKey
                                      completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
        XCTAssert(decryptedData != nil && error == nil);

        XCTAssert([decryptedData.value isEqualToData:someData]);

        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test02_KTC7_pullValue {
    XCTestExpectation *ex = [self expectationWithDescription:@""];

    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];

    [self.keyknoxManager pushValueWithIdentities:@[self.identity]
                                           root1:VSSCloudKeyStorage.root1
                                           root2:VSSCloudKeyStorage.root2
                                             key:VSSCloudKeyStorage.key
                                            data:someData
                                    previousHash:nil
                                      publicKeys:@[self.keyPair.publicKey]
                                      privateKey:self.keyPair.privateKey
                                      completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
        [self.keyknoxManager pullValueWithIdentity:self.identity
                                             root1:VSSCloudKeyStorage.root1
                                             root2:VSSCloudKeyStorage.root2
                                               key:VSSCloudKeyStorage.key
                                        publicKeys:@[self.keyPair.publicKey]
                                        privateKey:self.keyPair.privateKey completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
            XCTAssert(decryptedData != nil && error == nil);
            XCTAssert([decryptedData.value isEqualToData:someData]);

            [ex fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test03_KTC8_pullEmptyValue {
    XCTestExpectation *ex = [self expectationWithDescription:@""];

    [self.keyknoxManager pullValueWithIdentity:self.identity
                                         root1:VSSCloudKeyStorage.root1
                                         root2:VSSCloudKeyStorage.root2
                                           key:VSSCloudKeyStorage.key
                                    publicKeys:@[self.keyPair.publicKey]
                                    privateKey:self.keyPair.privateKey completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
        XCTAssert(decryptedData != nil && error == nil);
        XCTAssert(decryptedData.value.length == 0 && decryptedData.meta.length == 0);

        [ex fulfill];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

//- (void)test04_KTC9_pullMultiplePublicKeys {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    VSMVirgilPrivateKey *privateKey = nil;
//    NSMutableArray<VSMVirgilPublicKey *> *halfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *anotherHalfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//
//    for (int i = 0; i < self.numberOfKeys; i++) {
//        VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
//
//        if (i == 0)
//            privateKey = keyPair.privateKey;
//
//        if (i < self.numberOfKeys / 2)
//            [halfPublicKeys addObject:keyPair.publicKey];
//        else
//            [anotherHalfPublicKeys addObject:keyPair.publicKey];
//    }
//
//    VSSKeyknoxManager *keyknoxManager1 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                        publicKeys:halfPublicKeys
//                                                                        privateKey:privateKey];
//
//    [keyknoxManager1 pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//        XCTAssert([decryptedData.value isEqualToData:someData]);
//
//        [keyknoxManager1 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//            XCTAssert(decryptedData != nil && error == nil);
//            XCTAssert([decryptedData.value isEqualToData:someData]);
//
//            VSSKeyknoxManager *keyknoxManager2 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                publicKeys:anotherHalfPublicKeys
//                                                                                privateKey:privateKey];
//
//            [keyknoxManager2 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                XCTAssert(decryptedData == nil && error != nil);
//                XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                [ex fulfill];
//            }];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test05_KTC10_pullDifferentPrivateKeys {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSMutableArray<VSMVirgilKeyPair *> *keyPairs = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *publicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *halfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//
//    for (int i = 0; i < self.numberOfKeys; i++) {
//        VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
//
//        [keyPairs addObject:keyPair];
//        [publicKeys addObject:keyPair.publicKey];
//
//        if (i < self.numberOfKeys / 2)
//            [halfPublicKeys addObject:keyPair.publicKey];
//    }
//
//    uint32_t rand = arc4random_uniform(self.numberOfKeys / 2);
//
//    VSSKeyknoxManager *keyknoxManager1 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                        publicKeys:halfPublicKeys
//                                                                        privateKey:keyPairs[rand].privateKey];
//
//    [keyknoxManager1 pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//        XCTAssert([decryptedData.value isEqualToData:someData]);
//
//        uint32_t rand = arc4random_uniform(self.numberOfKeys / 2);
//
//        VSSKeyknoxManager *keyknoxManager2 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                            publicKeys:halfPublicKeys
//                                                                            privateKey:keyPairs[rand].privateKey];
//
//        [keyknoxManager2 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//            XCTAssert(decryptedData != nil && error == nil);
//            XCTAssert([decryptedData.value isEqualToData:someData]);
//
//            uint32_t rand = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//            VSSKeyknoxManager *keyknoxManager3 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                publicKeys:halfPublicKeys
//                                                                                privateKey:keyPairs[rand].privateKey];
//
//            [keyknoxManager3 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                XCTAssert(decryptedData == nil && error != nil);
//                XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                [ex fulfill];
//            }];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test06_KTC11_updateRecipients {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSMutableArray<VSMVirgilKeyPair *> *keyPairs = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *publicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *halfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *anotherHalfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//
//    for (int i = 0; i < self.numberOfKeys; i++) {
//        VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
//
//        [keyPairs addObject:keyPair];
//        [publicKeys addObject:keyPair.publicKey];
//
//        if (i < self.numberOfKeys / 2)
//            [halfPublicKeys addObject:keyPair.publicKey];
//        else
//            [anotherHalfPublicKeys addObject:keyPair.publicKey];
//    }
//
//    uint32_t rand = arc4random_uniform(self.numberOfKeys / 2);
//
//    VSSKeyknoxManager *keyknoxManager1 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                        publicKeys:halfPublicKeys
//                                                                        privateKey:keyPairs[rand].privateKey];
//
//    [keyknoxManager1 pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//        XCTAssert([decryptedData.value isEqualToData:someData]);
//
//        uint32_t rand1 = arc4random_uniform(self.numberOfKeys / 2);
//        uint32_t rand2 = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//        VSSKeyknoxManager *keyknoxManager2 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                            publicKeys:halfPublicKeys
//                                                                            privateKey:keyPairs[rand1].privateKey];
//
//        [keyknoxManager2 updateRecipientsWithNewPublicKeys:anotherHalfPublicKeys newPrivateKey:keyPairs[rand2].privateKey completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//            XCTAssert(decryptedData != nil && error == nil);
//            XCTAssert([decryptedData.value isEqualToData:someData]);
//
//            XCTAssert([keyknoxManager2.publicKeys isEqualToArray:anotherHalfPublicKeys]);
//            XCTAssert(keyknoxManager2.privateKey == keyPairs[rand2].privateKey);
//
//            uint32_t rand = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//            VSSKeyknoxManager *keyknoxManager3 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                publicKeys:anotherHalfPublicKeys
//                                                                                privateKey:keyPairs[rand].privateKey];
//
//            [keyknoxManager3 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                XCTAssert(decryptedData != nil && error == nil);
//                XCTAssert([decryptedData.value isEqualToData:someData]);
//
//                uint32_t rand = arc4random_uniform(self.numberOfKeys / 2);
//
//                VSSKeyknoxManager *keyknoxManager4 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                    publicKeys:anotherHalfPublicKeys
//                                                                                    privateKey:keyPairs[rand].privateKey];
//
//                [keyknoxManager4 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                    XCTAssert(decryptedData == nil && error != nil);
//                    XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                    XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                    uint32_t rand = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//                    VSSKeyknoxManager *keyknoxManager5 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                        publicKeys:halfPublicKeys
//                                                                                        privateKey:keyPairs[rand].privateKey];
//
//                    [keyknoxManager5 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                        XCTAssert(decryptedData == nil && error != nil);
//                        XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                        XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                        [ex fulfill];
//                    }];
//                }];
//            }];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test07_KTC12_updateRecipientsWithValue {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSMutableArray<VSMVirgilKeyPair *> *keyPairs = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *publicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *halfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *anotherHalfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//
//    for (int i = 0; i < self.numberOfKeys; i++) {
//        VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
//
//        [keyPairs addObject:keyPair];
//        [publicKeys addObject:keyPair.publicKey];
//
//        if (i < self.numberOfKeys / 2)
//            [halfPublicKeys addObject:keyPair.publicKey];
//        else
//            [anotherHalfPublicKeys addObject:keyPair.publicKey];
//    }
//
//    uint32_t rand = arc4random_uniform(self.numberOfKeys / 2);
//
//    VSSKeyknoxManager *keyknoxManager1 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                        publicKeys:halfPublicKeys
//                                                                        privateKey:keyPairs[rand].privateKey];
//
//    [keyknoxManager1 pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//        XCTAssert([decryptedData.value isEqualToData:someData]);
//
//        uint32_t rand = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//        [keyknoxManager1 updateRecipientsWithValue:decryptedData.value previousHash:decryptedData.keyknoxHash newPublicKeys:anotherHalfPublicKeys newPrivateKey:keyPairs[rand].privateKey completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//            XCTAssert(decryptedData != nil && error == nil);
//            XCTAssert([decryptedData.value isEqualToData:someData]);
//
//            uint32_t rand = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//            VSSKeyknoxManager *keyknoxManager2 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                publicKeys:anotherHalfPublicKeys
//                                                                                privateKey:keyPairs[rand].privateKey];
//
//            [keyknoxManager2 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                XCTAssert(decryptedData != nil && error == nil);
//                XCTAssert([decryptedData.value isEqualToData:someData]);
//
//                uint32_t rand = arc4random_uniform(self.numberOfKeys / 2);
//
//                VSSKeyknoxManager *keyknoxManager3 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                    publicKeys:anotherHalfPublicKeys
//                                                                                    privateKey:keyPairs[rand].privateKey];
//
//                [keyknoxManager3 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                    XCTAssert(decryptedData == nil && error != nil);
//                    XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                    XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                    VSSKeyknoxManager *keyknoxManager4 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                        publicKeys:anotherHalfPublicKeys
//                                                                                        privateKey:keyPairs[rand].privateKey];
//
//                    [keyknoxManager4 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                        XCTAssert(decryptedData == nil && error != nil);
//                        XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                        XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                        uint32_t rand = self.numberOfKeys / 2 + arc4random_uniform(self.numberOfKeys / 2);
//
//                        VSSKeyknoxManager *keyknoxManager5 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                                            publicKeys:halfPublicKeys
//                                                                                            privateKey:keyPairs[rand].privateKey];
//
//                        [keyknoxManager5 pullValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//                            XCTAssert(decryptedData == nil && error != nil);
//                            XCTAssert([error.domain isEqualToString:VSSKeyknoxCryptoErrorDomain]);
//                            XCTAssert(error.code == VSSKeyknoxCryptoErrorDecryptionFailed);
//
//                            [ex fulfill];
//                        }];
//                    }];
//                }];
//            }];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test08_KTC13_updateRecipientsEmptyValue {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSMutableArray<VSMVirgilKeyPair *> *keyPairs = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *halfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//    NSMutableArray<VSMVirgilPublicKey *> *anotherHalfPublicKeys = [[NSMutableArray alloc] initWithCapacity:self.numberOfKeys];
//
//    for (int i = 0; i < self.numberOfKeys; i++) {
//        VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
//
//        [keyPairs addObject:keyPair];
//
//        if (i < self.numberOfKeys / 2)
//            [halfPublicKeys addObject:keyPair.publicKey];
//        else
//            [anotherHalfPublicKeys addObject:keyPair.publicKey];
//    }
//
//    VSSKeyknoxManager *keyknoxManager = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                       publicKeys:halfPublicKeys
//                                                                       privateKey:keyPairs[0].privateKey];
//
//    [keyknoxManager updateRecipientsWithNewPublicKeys:anotherHalfPublicKeys newPrivateKey:keyPairs[25].privateKey completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//        XCTAssert(decryptedData.value.length == 0 && decryptedData.meta.length == 0 && [decryptedData.version isEqualToString:@"1.0"]);
//
//        [ex fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test09_KTC14_resetValue {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    [self.keyknoxManager pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//
//        [self.keyknoxManager resetValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//            XCTAssert(decryptedData != nil && error == nil);
//            XCTAssert(decryptedData.value.length == 0 && decryptedData.meta.length == 0);
//            XCTAssert([decryptedData.version isEqualToString:@"2.0"]);
//
//            [ex fulfill];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test10_KTC15_resetInvalidValue {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:nil];
//    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:nil];
//
//    VSSKeyknoxManager *keyknoxManager1 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                       publicKeys:@[keyPair1.publicKey]
//                                                                       privateKey:keyPair1.privateKey];
//
//    [keyknoxManager1 pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//        XCTAssert(decryptedData != nil && error == nil);
//
//        VSSKeyknoxManager *keyknoxManager2 = [self.utils setupKeyknoxManagerWithClient:self.keyknoxClient
//                                                                            publicKeys:@[keyPair2.publicKey]
//                                                                            privateKey:keyPair2.privateKey];
//
//        [keyknoxManager2 resetValueWithCompletion:^(VSSDecryptedKeyknoxValue *decryptedData, NSError *error) {
//            XCTAssert(decryptedData != nil && error == nil);
//            XCTAssert(decryptedData.value.length == 0 && decryptedData.meta.length == 0);
//            XCTAssert([decryptedData.version isEqualToString:@"2.0"]);
//
//            [ex fulfill];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}
//
//- (void)test11_KTC16_didEncrypt {
//    XCTestExpectation *ex = [self expectationWithDescription:@""];
//
//    NSData *someData = [[[NSUUID alloc] init].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
//
//    [self.keyknoxManager pushValue:someData previousHash:nil completion:^(VSSDecryptedKeyknoxValue *decryptedValue, NSError *error) {
//        XCTAssert(decryptedValue != nil && error == nil);
//
//        NSError *err;
//        VSSEncryptedKeyknoxValue *encryptedValue = [self.keyknoxClient pullValueAndReturnError:&err];
//
//        NSMutableData *data = [[NSMutableData alloc] init];
//
//        [data appendData:encryptedValue.meta];
//        [data appendData:encryptedValue.value];
//
//        NSData *decryptedData = [self.crypto decryptAndVerify:data with:self.keyPair.privateKey usingOneOf:@[self.keyPair.publicKey] error:&error];
//
//        XCTAssert(err == nil);
//
//        XCTAssert([decryptedData isEqualToData:someData]);
//
//        [ex fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}

@end
