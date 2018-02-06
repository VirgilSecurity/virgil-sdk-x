//
//  VSS003_ModelSignerCardVerifierTests.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/22/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCryptoApiImpl;
@import VirgilCrypto;

#import "VSSTestsConst.h"
#import "VSSTestUtils.h"

@interface VSSAccessTokenProviderMock: NSObject<VSSAccessTokenProvider>

@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSSTestUtils *utils;
@property NSInteger counter;

-(id)init;

-(id<VSSAccessToken>)getTokenWith:(VSSTokenContext *)tokenContext error:(NSError *__autoreleasing _Nullable *)error;

@end

@implementation VSSAccessTokenProviderMock

-(id)init {
    self = [super init];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    self.utils = [[VSSTestUtils alloc] initWithCrypto :self.crypto consts:self.consts];
    
    self.counter = 0;
    
    return self;
}

- (id<VSSAccessToken>)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext error:(NSError *__autoreleasing _Nullable * _Nullable)error {
    NSTimeInterval interval = (self.counter % 2) * 1000 + 1;
    self.counter++;
    
    id<VSSAccessToken> token = [self.utils getTokenWithIdentity:@"identity" ttl:interval error:error];
    
    sleep(2);
    
    return token;
}

@end

@interface VSS003_ModelSignerCardVerifierTests : XCTestCase

@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSMVirgilCardCrypto *cardCrypto;
@property (nonatomic) VSSTestUtils *utils;
@property (nonatomic) VSSCardClient *cardClient;
@property (nonatomic) VSSModelSigner *modelSigner;
@property (nonatomic) VSSVirgilCardVerifier *verifier;
@property (nonatomic) NSDictionary *testData;

@end

@implementation VSS003_ModelSignerCardVerifierTests

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    self.cardCrypto = [[VSMVirgilCardCrypto alloc] initWithVirgilCrypto:self.crypto];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL];
    self.modelSigner = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    self.verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:[[NSArray alloc] init]];
    
    self.verifier.verifySelfSignature   = false;
    self.verifier.verifyVirgilSignature = false;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test_data" ofType:@"txt"];
    NSData *dicData = [[NSData alloc] initWithContentsOfFile:path];
    XCTAssert(dicData != nil);
    
    self.testData = [NSJSONSerialization JSONObjectWithData:dicData options:kNilOptions error:nil];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test001 {
    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    NSData *data = [self.utils getRandomData];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data signatures:[[NSArray alloc] init]];
    XCTAssert(rawCard.signatures.count == 0);
    
    [self.modelSigner selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1.snapshot == nil);
    XCTAssert([signature1.signer isEqualToString:@"self"]);
    XCTAssert(([signature1.signature isEqualToString:@""]) == false);
    
    NSData *fingerprint = [self.cardCrypto generateSHA256For:data error:&error];
    BOOL success = [self.crypto verifySignature:[[NSData alloc] initWithBase64EncodedString:signature1.signature options:0] of:fingerprint with:keyPair1.publicKey];
    XCTAssert(success);
    
    [self.modelSigner selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
    error = nil;
    
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [self.modelSigner signWithModel:rawCard signer:@"extra" privateKey:keyPair2.privateKey additionalData:nil error:&error];
    XCTAssert(rawCard.signatures.count == 2 && error == nil);
    
    VSSRawSignature *signature2 = rawCard.signatures[1];
    XCTAssert(signature2.snapshot == nil && [signature2.signer isEqualToString:@"extra"]);
    XCTAssert(([signature2.signature isEqualToString:@""]) == false);
    
    success = [self.crypto verifySignature:[[NSData alloc] initWithBase64EncodedString:signature2.signature options:0] of:fingerprint with:keyPair2.publicKey];
    XCTAssert(success);
    
    [self.modelSigner signWithModel:rawCard signer:@"extra" privateKey:keyPair2.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
}

-(void)test002_withAdditionalData {
    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *data = [self.utils getRandomData];
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data signatures:[[NSArray alloc] init]];
    XCTAssert(rawCard.signatures.count == 0);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];
    NSData *dataDic = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    [self.modelSigner selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:dataDic error:&error];
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1 != nil);
    XCTAssert([signature1.snapshot isEqualToString:[dataDic base64EncodedStringWithOptions:0]]);
    XCTAssert([signature1.signer isEqualToString:@"self"]);
    XCTAssert(([signature1.signature isEqualToString:@""]) == false);
}

-(void)test003 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-10.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifySelfSignature = true;
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifyVirgilSignature = true;
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds1 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist1 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObject:creds1]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist1];

    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds21 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSVerifierCredentials *creds22 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist2 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObjects:creds21, creds22, nil]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist2];
    
   XCTAssert([self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds31 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSVerifierCredentials *creds32 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSVerifierCredentials *creds33 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist31 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObjects:creds31, creds32, nil]];
    VSSWhiteList *whitelist32 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObject:creds33]];
    self.verifier.whiteLists = [NSArray arrayWithObjects:whitelist31, whitelist32, nil];
    
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test004_NoSelfSignature_Should_Not_verify {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-11.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifySelfSignature = true;
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test005_NoVirgilSignature_Should_Not_verify {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-12.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifyVirgilSignature = true;
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test006_WrongSelfSignature_Should_Not_verify {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-14.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = true;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test007_WrongVirgilSignature_Should_Not_verify {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-15.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = true;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}


-(void)test008_WrongCustomSignature_Should_Not_verify {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-16.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    
    NSData *pubicKeyBase64 = [self.testData[@"STC-16.public_key1_base64"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert(pubicKeyBase64 != nil);
    
    VSSVerifierCredentials *creds1 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist1 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObject:creds1]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist1];
    
   XCTAssert(![self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds21 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:[self.utils getRandomData]];
    VSSVerifierCredentials *creds22 = [[VSSVerifierCredentials alloc] initWithSigner:@"FIXME" publicKey:pubicKeyBase64];
    VSSWhiteList *whitelist2 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObjects:creds21, creds22, nil]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist2];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
}

-(void)test009_Retry_forceGetToken_if_Not_Authorized {
    XCTestExpectation *ex = [self expectationWithDescription:@"All operations should proceed on second calls"];
    NSError *error;
    
    NSString *identity = @"identity";
    VSSAccessTokenProviderMock *tokenProvider = [[VSSAccessTokenProviderMock alloc] init];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: tokenProvider modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error != nil);
        XCTAssert([[error localizedDescription] isEqualToString:@"token has expired"]);
        XCTAssert([error code] == 20304);
        
        [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil timeout:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);

            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
            
            [cardManager getCardWithId:card.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
                XCTAssert(error != nil);
                XCTAssert([[error localizedDescription] isEqualToString:@"token has expired"]);
                XCTAssert([error code] == 20304);
                
                [cardManager getCardWithId:card.identifier timeout:nil completion:^(VSSCard * returnedCard, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCard != nil);
                    
                    XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
                    
                    [cardManager searchCardsWithIdentity:identity timeout:nil completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                        XCTAssert(error != nil);
                        XCTAssert([[error localizedDescription] isEqualToString:@"token has expired"]);
                        XCTAssert([error code] == 20304);
                        
                        [cardManager searchCardsWithIdentity:identity timeout:nil completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                            XCTAssert(error == nil);
                            
                            BOOL founded = false;
                            for (VSSCard* returnedCard in returnedCards) {
                                if ([returnedCard.identifier isEqualToString:card.identifier]) {
                                    XCTAssert([self.utils isCardsEqualWithCard:returnedCard and:card]);
                                    founded = true;
                                }
                            }
                            XCTAssert(founded);
                            
                            [ex fulfill];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:8. handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
