//
//  VSS005_CardManagerTests.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/30/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCrypto;

#import "VSSTestsConst.h"
#import "VSSTestUtils.h"

static const NSTimeInterval timeout = 8.;

@interface VSSAccessTokenProviderMock: NSObject<VSSAccessTokenProvider>

@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSSTestUtils *utils;
@property NSInteger counter;

-(id)init;

- (void)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext completion:(void (^ _Nonnull)(id<VSSAccessToken> _Nullable, NSError * _Nullable))completion;

@end

@implementation VSSAccessTokenProviderMock

-(id)init {
    self = [super init];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:NO];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    
    self.counter = 0;
    
    return self;
}

- (void)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext completion:(void (^ _Nonnull)(id<VSSAccessToken> _Nullable, NSError * _Nullable))completion {
    NSTimeInterval interval = (self.counter % 2) * 1000 + 1;
    self.counter++;
    
    NSError *error;
    id<VSSAccessToken> token = [self.utils getTokenWithIdentity:@"identity" ttl:interval error:&error];
    
    sleep(2);
    
    completion(token, error);
}

@end

@interface VSS005_CardManagerTests : XCTestCase

@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSMVirgilCardCrypto *cardCrypto;
@property (nonatomic) VSSTestUtils *utils;
@property (nonatomic) VSSCardClient *cardClient;
@property (nonatomic) VSSModelSigner *modelSigner;
@property (nonatomic) VSSVirgilCardVerifier *verifier;

@end

@implementation VSS005_CardManagerTests

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    self.cardCrypto = [[VSMVirgilCardCrypto alloc] initWithVirgilCrypto:self.crypto];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.modelSigner = [[VSSModelSigner alloc] initWithCardCrypto:self.cardCrypto];
    self.verifier = [[VSSVirgilCardVerifier alloc] initWithCardCrypto:self.cardCrypto whitelists:@[]];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL];
}

- (void)tearDown {
    [super tearDown];
}

-(void)test001_STC_17 {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get"];
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = self.cardClient;
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        XCTAssert(card.isOutdated == false);
        
        [cardManager getCardWithId:card.identifier completion:^(VSSCard *card1, NSError *error) {
            XCTAssert(error == nil && card1 != nil);
            XCTAssert(card1.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card and:card1]);
            
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
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = self.cardClient;
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];

    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:dic completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        XCTAssert(card.isOutdated == false);
        XCTAssert([[self.utils getSelfSignatureFromCard:card].extraFields isEqualToDictionary:dic]);

        [cardManager getCardWithId:card.identifier completion:^(VSSCard *card1, NSError *error) {
            XCTAssert(error == nil && card1 != nil);
            XCTAssert(card1.isOutdated == false);

            XCTAssert([self.utils isCardsEqualWithCard:card and:card1]);

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

    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = self.cardClient;
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

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

    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);

    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = self.cardClient;
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];

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

                [cardManager searchCardsWithIdentity:identity completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCards.count == 2);
                    card2.previousCard = card1;
                    card1.isOutdated = true;

                    for (VSSCard* card in returnedCards) {
                        if ([card.identifier isEqualToString:card2.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard:card and:card2]);
                            XCTAssert([self.utils isCardsEqualWithCard:card.previousCard and:card1]);
                            XCTAssert([card.previousCardId isEqualToString:card1.identifier]);
                        }
                        else if ([card.identifier isEqualToString:card3.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard:card and:card3]);
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

    NSError *error;
    NSString *identity =[[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
    NSData *publicKeyData = [self.crypto exportPublicKey:keyPair.publicKey];
    VSSVerifierCredentials *creds = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:publicKeyData];
    VSSWhitelist *whitelist = [[VSSWhitelist alloc] initWithVerifiersCredentials:@[creds] error:&error];
    XCTAssert(error == nil);
    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCardCrypto:self.cardCrypto whitelists:@[whitelist]];
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:generator cardVerifier:verifier];
    cardManagerParams.cardClient = self.cardClient;
    
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
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:generator cardVerifier:self.verifier];
    cardManagerParams.cardClient = self.cardClient;
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithRawCard:rawCard completion:^(VSSCard *card, NSError *error) {
        XCTAssert(error == nil && card != nil);
        XCTAssert(card.isOutdated == false);
        
        [cardManager getCardWithId:card.identifier completion:^(VSSCard *card1, NSError *error) {
            XCTAssert(error == nil && card1 != nil);
            XCTAssert(card1.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card and:card1]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

//-(void)test006_STC_26 {
//    XCTestExpectation *ex = [self expectationWithDescription:@"All operations should proceed on second calls"];
//    NSError *error;
//
//    NSString *identity = @"identity";
//    VSSAccessTokenProviderMock *tokenProvider = [[VSSAccessTokenProviderMock alloc] init];
//
//    VSSCardManagerParams *cardManagerParams = [[VSSCardManagerParams alloc] initWithCardCrypto:self.cardCrypto accessTokenProvider:tokenProvider cardVerifier:self.verifier];
//    cardManagerParams.cardClient = self.cardClient;
//
//    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:cardManagerParams];
//
//    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
//    XCTAssert(error == nil);
//
//    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *returnedCard1, NSError *error) {
//        XCTAssert(error != nil);
//        XCTAssert([error code] == 20304);
//
//        [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard *returnedCard, NSError *error) {
//            XCTAssert(error == nil);
//            XCTAssert(returnedCard != nil);
//
//            NSError *err;
//            VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:returnedCard1.identifier extraFields:nil error:&err];
//            XCTAssert(err == nil);
//            VSSCard *card = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:rawCard];
//            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
//
//            [cardManager getCardWithId:card.identifier completion:^(VSSCard *returnedCard, NSError *error) {
//                XCTAssert(error != nil);
//                XCTAssert([error code] == 20304);
//
//                [cardManager getCardWithId:card.identifier completion:^(VSSCard *returnedCard, NSError *error) {
//                    XCTAssert(error == nil);
//                    XCTAssert(returnedCard != nil);
//
//                    XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
//
//                    [cardManager searchCardsWithIdentity:identity completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
//                        XCTAssert(error != nil);
//                        XCTAssert([error code] == 20304);
//
//                        [cardManager searchCardsWithIdentity:identity completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
//                            XCTAssert(error == nil);
//
//                            BOOL found = false;
//                            for (VSSCard* returnedCard in returnedCards) {
//                                if ([returnedCard.identifier isEqualToString:card.identifier]) {
//                                    XCTAssert([self.utils isCardsEqualWithCard:returnedCard and:card]);
//                                    found = true;
//                                }
//                            }
//                            XCTAssert(found);
//
//                            [ex fulfill];
//                        }];
//                    }];
//                }];
//            }];
//        }];
//    }];
//
//    [self waitForExpectationsWithTimeout:15. handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
//}

@end
