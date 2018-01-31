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

@interface VSS005_CardManagerTests : XCTestCase

@property (nonatomic) VSSTestsConst         * consts;
@property (nonatomic) VSMVirgilCrypto       * crypto;
@property (nonatomic) VSMVirgilCardCrypto   * cardCrypto;
@property (nonatomic) VSSTestUtils          * utils;
@property (nonatomic) VSSCardClient         * cardClient;
@property (nonatomic) VSSModelSigner        * modelSigner;
@property (nonatomic) VSSVirgilCardVerifier *verifier;

@end

@implementation VSS005_CardManagerTests

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] init];
    self.cardCrypto = [[VSMVirgilCardCrypto alloc] init];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.modelSigner = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    self.verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:nil];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL connection:nil];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test001 {
    
}

-(void)test002_Publish_And_Get {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *params = [[VSSCardManagerParams alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner serviceUrl:[self.consts serviceURL] cardVerifier:self.verifier signCallback:nil];
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:params];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        
        [cardManager getCardWithId:card.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        }];
    }];
}

-(void)test003_Publish_And_Get_With_extaData {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *params = [[VSSCardManagerParams alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner serviceUrl:[self.consts serviceURL] cardVerifier:self.verifier signCallback:nil];
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:params];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:dic error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil timeout:nil extraFields:dic completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        
        [cardManager getCardWithId:card.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
        }];
    }];
}

-(void)test004_CardReplacement {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *params = [[VSSCardManagerParams alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner serviceUrl:[self.consts serviceURL] cardVerifier:self.verifier signCallback:nil];
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:params];
    
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard1 = [cardManager generateRawCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card1 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard1];
    
    VSSRawSignedModel *rawCard2 = [cardManager generateRawCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity previousCardId:card1.identifier extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card2 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard2];
    
    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);
        
        [cardManager getCardWithId:card1.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);
            
            [cardManager publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity previousCardId:returnedCard.identifier timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
                XCTAssert(error == nil);
                XCTAssert(returnedCard != nil);
                XCTAssert(returnedCard.isOutdated == false);
                
                XCTAssert([self.utils isCardsEqualWithCard:card2 and:returnedCard]);
                
                [cardManager getCardWithId:card2.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCard != nil);
                    XCTAssert(returnedCard.isOutdated == false);
                    
                    XCTAssert([self.utils isCardsEqualWithCard:card2 and:returnedCard]);
                    
                    [cardManager getCardWithId:card1.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
                        XCTAssert(error == nil);
                        XCTAssert(returnedCard != nil);
                        XCTAssert(returnedCard.isOutdated == true);
                        
                        XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);
                    }];
                }];
            }];
        }];
    }];
}

-(void)test005_SearchCards {
    NSError *error;
    NSString *identity1 = [[NSUUID alloc] init].UUIDString;
    NSString *identity2 = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity1 error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *params = [[VSSCardManagerParams alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner serviceUrl:[self.consts serviceURL] cardVerifier:self.verifier signCallback:nil];
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:params];
    
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    VSMVirgilKeyPair *keyPair3 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard1 = [cardManager generateRawCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity1 previousCardId:nil extraFields:nil error:&error];
    VSSCard *card1 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard1];
    
    VSSRawSignedModel *rawCard2 = [cardManager generateRawCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity2 previousCardId:card1.identifier extraFields:nil error:&error];
    VSSCard *card2 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard2];
    
    VSSRawSignedModel *rawCard3 = [cardManager generateRawCardWithPrivateKey:keyPair3.privateKey publicKey:keyPair3.publicKey identity:identity2 previousCardId:nil extraFields:nil error:&error];
    VSSCard *card3 = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard3];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithPrivateKey:keyPair1.privateKey publicKey:keyPair1.publicKey identity:identity1 previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card1 and:returnedCard]);
        
        [cardManager publishCardWithPrivateKey:keyPair2.privateKey publicKey:keyPair2.publicKey identity:identity2 previousCardId:returnedCard.identifier timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);
            XCTAssert(returnedCard.isOutdated == false);
            
            XCTAssert([self.utils isCardsEqualWithCard:card2 and:returnedCard]);
            
            [cardManager publishCardWithPrivateKey:keyPair3.privateKey publicKey:keyPair3.publicKey identity:identity2 previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
                XCTAssert(error == nil);
                XCTAssert(returnedCard != nil);
                XCTAssert(returnedCard.isOutdated == false);
                
                XCTAssert([self.utils isCardsEqualWithCard:card3 and:returnedCard]);
                
                [cardManager searchCardsWithIdentity:identity2 timeout:nil completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCards.count == 2);
                    
                    for (VSSCard* card in returnedCards) {
                        if ([card.identifier isEqualToString:card2.identifier]) {
                            XCTAssert([self.utils isCardsEqualWithCard:card and:card2]);
                            XCTAssert([self.utils isCardsEqualWithCard:card.previousCard and:card1]);
                            XCTAssert([card.previousCardId isEqualToString:card1.identifier]);
                        } else {
                            XCTAssert([self.utils isCardsEqualWithCard:card and:card3]);
                        }
                    }

                }];
            }];
        }];
    }];
}

- (void)test006_generateRawCard{
    NSError *error;
    NSString *identity =[[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManagerParams *addParams = [[VSSCardManagerParams alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner serviceUrl:[self.consts serviceURL] cardVerifier:self.verifier signCallback:nil];
    VSSCardManager *addCardManager = [[VSSCardManager alloc] initWithParams:addParams];
    
    VSSCardManagerParams *params = [[VSSCardManagerParams alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner serviceUrl:[self.consts serviceURL] cardVerifier:self.verifier signCallback:^VSSRawSignedModel *(VSSRawSignedModel *model) {
            VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:nil];
            VSSRawSignedModel *rawCard = [addCardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:nil];
            VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
        
            [self.modelSigner signWithModel:model id:card.identifier type:VSSSignerTypeExtra privateKey:keyPair.privateKey additionalData:nil error:nil];

            return  model;
        }];
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:params];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithSnapshot:rawCard.contentSnapshot];
    
    XCTAssert([content.identity isEqualToString:identity]);
    XCTAssert([content.version isEqualToString:@"5.0"]);
    XCTAssert(content.previousCardId == nil);
    XCTAssert(rawCard.signatures.count == 2);
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert(returnedCard != nil);
        XCTAssert(returnedCard.isOutdated == false);
        
        XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
    }];
}


@end


