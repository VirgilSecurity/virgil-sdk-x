//
// Copyright (C) 2015-2020 Virgil Security Inc.
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

@interface VSSAccessTokenProviderMock: NSObject<VSSAccessTokenProvider>

@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) TestUtils *utils;
@property (nonatomic) NSString *identity;
@property (nonatomic) void (^forceCallback)(BOOL) ;
@property NSInteger counter;

-(id)initWithIdentity:(NSString *)identity forceCallback:(void (^)(BOOL))forceCallback;

- (void)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext completion:(void (^ _Nonnull)(id<VSSAccessToken> _Nullable, NSError * _Nullable))completion;

@end

@implementation VSSAccessTokenProviderMock

-(id)initWithIdentity:(NSString *)identity forceCallback:(void (^)(BOOL))forceCallback {
    self = [super init];

    self.identity = [identity copy];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:NO error:nil];
    self.utils = [TestUtils readFromBundle];
    self.forceCallback = forceCallback;
    self.counter = 0;

    return self;
}

- (void)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext completion:(void (^ _Nonnull)(id<VSSAccessToken> _Nullable, NSError * _Nullable))completion {
    NSTimeInterval interval = (self.counter % 2) == 0 ? 5 : 1000;
    self.forceCallback(tokenContext.forceReload);

    id<VSSAccessToken> token = [self.utils generateTokenWithIdentity:self.identity ttl:interval];

    if (self.counter % 2 == 0)
        sleep(10);

    self.counter++;

    completion(token, nil);
}

@end

static const NSTimeInterval timeout = 20.;

@interface VSS005_CardManagerTests : VSSTestBase

@property (nonatomic) VSSModelSigner *modelSigner;
@property (nonatomic) VSSVirgilCardVerifier *verifier;

@end

@implementation VSS005_CardManagerTests

- (void)setUp {
    [super setUp];
    
    self.verifier = [self.utils setupVerifierWithWhitelists:@[]];
    self.modelSigner = [[VSSModelSigner alloc] initWithCrypto:self.crypto];
}

- (void)tearDown {
    [super tearDown];
}

-(void)test001_STC_17 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get"];

    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    NSError *error;
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card1, NSError *error) {
        XCTAssert(error == nil && card1 != nil);
        XCTAssert(card1.isOutdated == false);
        
        [cardManager getCardWithId:card1.identifier completion:^(VSSCard *card2, NSError *error) {
            XCTAssert(error == nil && card2 != nil);
            XCTAssert(card2.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard1:card1 card2:card2]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test002_STC_18 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get with extra data"];

    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:[self.utils getGeneratorJwtProviderWithIdentity:identity] cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];

    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:dic completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        XCTAssert(card.isOutdated == false);

        [cardManager getCardWithId:card.identifier completion:^(VSSCard *card1, NSError *error) {
            XCTAssert(error == nil && card1 != nil);
            XCTAssert(card1.isOutdated == false);

            [ex fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test003_STC_19 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be replaced"];

    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card1, NSError *error) {
        XCTAssert(error == nil && card1 != nil);

        [cardManager publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity previousCardId:card1.identifier extraFields:nil completion:^(VSSCard *card2, NSError *error) {
            XCTAssert(error == nil && card2 != nil);
            XCTAssert(card2.isOutdated == false);

            [cardManager getCardWithId:card1.identifier completion:^(VSSCard *card11, NSError *error) {
                XCTAssert(error == nil && card11 != nil);
                XCTAssert(card11.isOutdated == YES);

                [cardManager getCardWithId:card2.identifier completion:^(VSSCard *card21, NSError *error) {
                    XCTAssert(error == nil && card21 != nil);
                    XCTAssert(card21.isOutdated == NO);
                    XCTAssert([card21.previousCardId isEqualToString:card1.identifier]);

                    [ex fulfill];
                }];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test004_STC_20 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Cards should be published and searched"];

    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair3 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card1, NSError *error) {
        XCTAssert(error == nil && card1 != nil);

        [cardManager publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity previousCardId:card1.identifier extraFields:nil completion:^(VSSCard *card2, NSError *error) {
            XCTAssert(error == nil && card2 != nil);

            [cardManager publishCardWithPrivateKey:keyPair3.privateKey publicKey:keyPair3.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card3, NSError *error) {
                XCTAssert(error == nil && card3 != nil);

                [cardManager searchCardsWithIdentities:@[identity] completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCards.count == 2);
                    card2.previousCard = card1;
                    card1.isOutdated = true;

                    for (VSSCard* card in returnedCards) {
                        if ([card.identifier isEqualToString:card2.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard1:card card2:card2]);
                            XCTAssert([self.utils isCardsEqualWithCard1:card.previousCard card2:card1]);
                            XCTAssert([card.previousCardId isEqualToString:card1.identifier]);
                        }
                        else if ([card.identifier isEqualToString:card3.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard1:card card2:card3]);
                        }
                        else {
                            XCTFail();
                        }
                    }

                    [ex fulfill];
                }];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test005_STC_21 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published"];

    NSString *identity =[[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];

    NSError *error;
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    VSSVerifierCredentials *creds = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:keyPair.publicKey];
    VSSWhitelist *whitelist1 = [[VSSWhitelist alloc] initWithVerifiersCredentials:@[creds] error:&error];
    XCTAssert(error == nil);

    VSSVirgilCardVerifier *verifier = [self.utils setupVerifierWithWhitelists:@[whitelist1]];
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    cardManagerParams.signCallback = ^void(VSSRawSignedModel *model, void (^ completionHandler)(VSSRawSignedModel *signedModel, NSError* error)) {
        NSError *error;
        [self.modelSigner signWithModel:model signer:@"extra" privateKey:keyPair.privateKey additionalData:nil error:&error];
        
        completionHandler(model, error);
    };
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];
    
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        
        XCTAssert(card.signatures.count == 3);
        
        [ex fulfill];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test006_PublishRawCard {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get"];

    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];

    NSError *error;
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithRawCard:rawCard completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        XCTAssert(card.isOutdated == false);
        
        [cardManager getCardWithId:card.identifier completion:^(VSSCard *card1, NSError *error) {
            XCTAssert(error == nil && card1 != nil);
            XCTAssert(card1.isOutdated == false);

            XCTAssert([self.utils isCardsEqualWithCard1:card card2:card1]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test007_ImportExportRawCard {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get"];

    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    NSError *error;
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithRawCard:rawCard completion:^(VSSCard *card, NSError *error) {
        NSError *err;
        
        VSSRawSignedModel *rawCard = [cardManager exportCardAsRawCard:card error:&err];
        XCTAssert(err == nil);
        XCTAssert([rawCard.contentSnapshot isEqualToData:card.contentSnapshot]);
        XCTAssert(rawCard.signatures.count == card.signatures.count);
        XCTAssert(rawCard.signatures.count == 2);
        
        NSData *signature1;
        NSData *signature2;
        for (VSSCardSignature *cardSignature in card.signatures) {
            if ([cardSignature.signer isEqualToString:@"self"]) {
                signature1 = cardSignature.signature;
            }
        }
        
        for (VSSRawSignature *rawSignature in rawCard.signatures) {
            if ([rawSignature.signer isEqualToString:@"self"]) {
                signature2 = rawSignature.signature;
            }
        }
        
        XCTAssert([signature1 isEqualToData:signature2]);
        
        VSSCard *card1 = [cardManager importCardFromRawCard:rawCard error:&err];
        XCTAssert(err == nil);

        XCTAssert([self.utils isCardsEqualWithCard1:card card2:card1]);
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test008_STC_26 {
    XCTestExpectation *ex = [self expectationWithDescription:@"All operations should proceed on second calls"];
    NSError *error;
    
    NSTimeInterval timeout = 50.;

    NSInteger __block counter = 0;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> tokenProvider = [[VSSAccessTokenProviderMock alloc] initWithIdentity:identity forceCallback:^(BOOL force) {
        if (counter % 2 == 0)
            XCTAssert(!force);
        else
            XCTAssert(force);

        counter++;
    }];

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:tokenProvider cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithTokenProvider:tokenProvider];

    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *publishedCard, NSError *error) {
        XCTAssert(error == nil && publishedCard != nil);

        [cardManager getCardWithId:publishedCard.identifier completion:^(VSSCard *returnedCard, NSError *error) {
            XCTAssert(error == nil && returnedCard != nil);

            [cardManager searchCardsWithIdentities:@[identity] completion:^(NSArray<VSSCard *> *foundCards, NSError *error) {
                XCTAssert(error == nil && foundCards.count == 1);
                
                [ex fulfill];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test009_STC_42 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Cards should be published and searched"];

    NSString *identity1 = [[NSUUID alloc] init].UUIDString;
    NSString *identity2 = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator1 = [self.utils getGeneratorJwtProviderWithIdentity:identity1];
    id<VSSAccessTokenProvider> generator2 = [self.utils getGeneratorJwtProviderWithIdentity:identity2];
    
    VSSCardManagerParams *cardManagerParams1 = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator1 cardVerifier:self.verifier];
    cardManagerParams1.cardClient = [self.utils setupClientWithIdentity:identity1];
    
    VSSCardManagerParams *cardManagerParams2 = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator2 cardVerifier:self.verifier];
    cardManagerParams2.cardClient = [self.utils setupClientWithIdentity:identity2];
    
    VSSCardManager *cardManager1 = [[VSSCardManager alloc] initWithParams:cardManagerParams1];
    VSSCardManager *cardManager2 = [[VSSCardManager alloc] initWithParams:cardManagerParams2];

    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair3 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [cardManager1 publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity1 previousCardId:nil extraFields:nil completion:^(VSSCard *card1, NSError *error) {
        XCTAssert(error == nil && card1 != nil);
        
        [cardManager1 publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity1 previousCardId:card1.identifier extraFields:nil completion:^(VSSCard *card2, NSError *error) {
            XCTAssert(error == nil && card2 != nil);
            
            [cardManager2 publishCardWithPrivateKey:keyPair3.privateKey publicKey:keyPair3.publicKey identity:identity2 previousCardId:nil extraFields:nil completion:^(VSSCard *card3, NSError *error) {
                XCTAssert(error == nil && card3 != nil);
                
                [cardManager1 searchCardsWithIdentities:@[identity1, identity2] completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCards.count == 2);
                    card2.previousCard = card1;
                    card1.isOutdated = true;
                    
                    for (VSSCard* card in returnedCards) {
                        if ([card.identifier isEqualToString:card2.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard1:card card2:card2]);
                            XCTAssert([self.utils isCardsEqualWithCard1:card.previousCard card2:card1]);
                            XCTAssert([card.previousCardId isEqualToString:card1.identifier]);
                        }
                        else if ([card.identifier isEqualToString:card3.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard1:card card2:card3]);
                        }
                        else {
                            XCTFail();
                        }
                    }
                    
                    [ex fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)test010_RevokeCard {
    XCTestExpectation *ex = [self expectationWithDescription:@""];
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    id<VSSAccessTokenProvider> generator = [self.utils getGeneratorJwtProviderWithIdentity:identity];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCrypto:self.crypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = [self.utils setupClientWithIdentity:identity];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        XCTAssert(card.isOutdated == false);
        
        [cardManager revokeCardWithId:card.identifier completion:^(NSError *error) {
            XCTAssert(error == nil);
            
            [cardManager getCardWithId:card.identifier completion:^(VSSCard *card1, NSError *error) {
                XCTAssert(error == nil && card1 != nil);
                XCTAssert(card1.isOutdated == true);
                
                [ex fulfill];
            }];
        }];

    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
