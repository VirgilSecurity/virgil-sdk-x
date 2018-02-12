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
    self.modelSigner = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    self.verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:[[NSArray alloc] init]];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test001 {
    
}

-(void)test002_Publish_And_Get {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get"];
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        
        [cardManager getCardWithId:card.identifier completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test003_Publish_And_Get_With_extaData {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published and get with extra data"];
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:dic error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:dic completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        
        [cardManager getCardWithId:card.identifier completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test004_CardReplacement {
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be replaced"];
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard1 = [cardManager generateRawCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card1 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard1];

    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);
        
        [cardManager getCardWithId:card1.identifier completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);

            VSSRawSignedModel *rawCard2 = [cardManager generateRawCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity previousCardId:card1.identifier extraFields:nil error:&error];
            XCTAssert(error == nil);
            VSSCard *card2 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard2];
            [cardManager publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity previousCardId:returnedCard.identifier extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
                XCTAssert(error == nil);
                XCTAssert(returnedCard != nil);
                XCTAssert(returnedCard.isOutdated == false);

                XCTAssert([self.utils isCardsEqualWithCard:card2 and:returnedCard]);
                
                [cardManager getCardWithId:card2.identifier completion:^(VSSCard * returnedCard, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCard != nil);
                    XCTAssert(returnedCard.isOutdated == false);
                    
                    XCTAssert([self.utils isCardsEqualWithCard:card2 and:returnedCard]);
                    
                    [cardManager getCardWithId:card1.identifier completion:^(VSSCard * returnedCard, NSError *error) {
                        XCTAssert(error == nil);
                        XCTAssert(returnedCard != nil);
                        XCTAssert(returnedCard.isOutdated == true);
                        
                        XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);
                        
                        [ex fulfill];
                    }];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test005_SearchCards {
    XCTestExpectation *ex = [self expectationWithDescription:@"Cards should be published and searched"];
    
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair3 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard1 = [cardManager generateRawCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    VSSCard *card1 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard1];
    
    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);

        VSSRawSignedModel *rawCard2 = [cardManager generateRawCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:returnedCard.identity previousCardId:returnedCard.identifier extraFields:nil error:&error];
        VSSCard *card2 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard2];
        [cardManager publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:returnedCard.identity previousCardId:returnedCard.identifier extraFields:nil completion:^(VSSCard *returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);

            XCTAssert([self.utils isCardsEqualWithCard:card2 and:returnedCard]);

            VSSRawSignedModel *rawCard3 = [cardManager generateRawCardWithPrivateKey:keyPair3.privateKey publicKey:keyPair3.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
            VSSCard *card3 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard3];
            [cardManager publishCardWithPrivateKey:keyPair3.privateKey publicKey:keyPair3.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
                XCTAssert(error == nil);
                XCTAssert(returnedCard != nil);
                XCTAssert(returnedCard.isOutdated == false);

                XCTAssert([self.utils isCardsEqualWithCard:card3 and:returnedCard]);

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
                        } else {
                            XCTAssert([self.utils isCardsEqualWithCard:card and:card3]);
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

- (void)test006_generateRawCard{
    XCTestExpectation *ex = [self expectationWithDescription:@"Card should be published"];

    NSError *error;
    NSString *identity =[[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);

    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:^void(VSSRawSignedModel *model, void (^ completionHandler)(VSSRawSignedModel * signedModel, NSError* error)) {
        NSError *error;
        VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];

        [self.modelSigner signWithModel:model signer:@"extra" privateKey:keyPair.privateKey additionalData:nil error:&error];

        completionHandler(model, error);
    }];

    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithSnapshot:rawCard.contentSnapshot];

    XCTAssert([content.identity isEqualToString:identity]);
    XCTAssert([content.version isEqualToString:@"5.0"]);
    XCTAssert(content.previousCardId == nil);
    XCTAssert(rawCard.signatures.count == 1);

    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);

        XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        [ex fulfill];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
