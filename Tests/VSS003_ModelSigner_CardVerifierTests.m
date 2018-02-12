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

- (void)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext completion:(void (^ _Nonnull)(id<VSSAccessToken> _Nullable, NSError * _Nullable))completion;

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

- (void)getTokenWith:(VSSTokenContext * _Nonnull)tokenContext completion:(void (^ _Nonnull)(id<VSSAccessToken> _Nullable, NSError * _Nullable))completion {
    NSTimeInterval interval = (self.counter % 2) * 1000 + 1;
    self.counter++;

    NSError *error;
    id<VSSAccessToken> token = [self.utils getTokenWithIdentity:@"identity" ttl:interval error:&error];
    
    sleep(2);
    
    completion(token, error);
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

- (void)test001_STC_8 {
    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    NSData *data = [self.utils getRandomData];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data];
    XCTAssert(rawCard.signatures.count == 0);
    
    [self.modelSigner selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1.snapshot == nil);
    XCTAssert([signature1.signer isEqualToString:@"self"]);
    XCTAssert(([signature1.signature isEqualToString:@""]) == false);

    BOOL success = [self.crypto verifySignature:[[NSData alloc] initWithBase64EncodedString:signature1.signature options:0] of:data with:keyPair1.publicKey];
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
    
    success = [self.crypto verifySignature:[[NSData alloc] initWithBase64EncodedString:signature2.signature options:0] of:data with:keyPair2.publicKey];
    XCTAssert(success);
    
    [self.modelSigner signWithModel:rawCard signer:@"extra" privateKey:keyPair2.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
}

-(void)test002_STC_9 {
    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *data = [self.utils getRandomData];
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data];
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

-(void)test003_STC_10 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider:generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-10.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString error:&error];
    XCTAssert(card != nil && error == nil);

    NSString *privateKey1Base64 = self.testData[@"STC-10.private_key1_base64"];
    VSMVirgilPrivateKeyExporter *exporter = [[VSMVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:self.crypto password:nil];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:privateKey1Base64 options:0];
    VSMVirgilPrivateKey *privateKey = (VSMVirgilPrivateKey *)[exporter importPrivateKeyFrom:data error:&error];
    XCTAssert(error == nil);

    VSMVirgilPublicKey *publicKey1 = [self.crypto extractPublicKeyFrom:privateKey error:&error];
    NSData *publicKey1Data = [self.crypto exportPublicKey:publicKey1];
    XCTAssert(error == nil);

    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifySelfSignature = true;
    XCTAssert([self.verifier verifyCardWithCard:card]);

    // FIXME Will appear as Vasilina fix
    //self.verifier.verifyVirgilSignature = true;
    //XCTAssert([self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds1 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:publicKey1Data];
    VSSWhiteList *whitelist1 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObject:creds1]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist1];

    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds21 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:publicKey1Data];
    VSSVerifierCredentials *creds22 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist2 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObjects:creds21, creds22, nil]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist2];
    
   XCTAssert([self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds31 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:publicKey1Data];
    VSSVerifierCredentials *creds32 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:[self.utils getRandomData]];
    VSSVerifierCredentials *creds33 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist31 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObjects:creds31, creds32, nil]];
    VSSWhiteList *whitelist32 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObject:creds33]];
    self.verifier.whiteLists = [NSArray arrayWithObjects:whitelist31, whitelist32, nil];
    
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test004_STC_11 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-11.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString error:&error];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifySelfSignature = true;
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test005_STC_12 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-12.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString error:&error];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
    
    self.verifier.verifyVirgilSignature = true;
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test006_STC_14 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-14.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString error:&error];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = true;
    self.verifier.verifyVirgilSignature = false;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}

-(void)test007_STC_15 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-15.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString error:&error];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = true;
    self.verifier.whiteLists = [[NSArray<VSSWhiteList *> alloc] init];
    
    XCTAssert(![self.verifier verifyCardWithCard:card]);
}


-(void)test008_STC_16 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    NSString *cardString = self.testData[@"STC-16.as_string"];
    XCTAssert(error == nil);
    VSSCard *card = [cardManager importCardWithString:cardString error:&error];
    XCTAssert(card != nil);
    
    self.verifier.verifySelfSignature = false;
    self.verifier.verifyVirgilSignature = false;
    
    NSData *pubicKeyBase64 = [[NSData alloc] initWithBase64EncodedString:self.testData[@"STC-16.public_key1_base64"] options:0];
    XCTAssert(pubicKeyBase64 != nil);
    
    VSSVerifierCredentials *creds1 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:[self.utils getRandomData]];
    VSSWhiteList *whitelist1 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObject:creds1]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist1];
    
   XCTAssert(![self.verifier verifyCardWithCard:card]);
    
    VSSVerifierCredentials *creds21 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:[self.utils getRandomData]];
    VSSVerifierCredentials *creds22 = [[VSSVerifierCredentials alloc] initWithSigner:@"extra" publicKey:pubicKeyBase64];
    VSSWhiteList *whitelist2 = [[VSSWhiteList alloc] initWithVerifiersCredentials:[NSArray arrayWithObjects:creds21, creds22, nil]];
    self.verifier.whiteLists = [NSArray arrayWithObject:whitelist2];
    
    XCTAssert([self.verifier verifyCardWithCard:card]);
}

-(void)test009_STC_26 {
    XCTestExpectation *ex = [self expectationWithDescription:@"All operations should proceed on second calls"];
    NSError *error;
    
    NSString *identity = @"identity";
    VSSAccessTokenProviderMock *tokenProvider = [[VSSAccessTokenProviderMock alloc] init];
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: tokenProvider modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier retryOnUnauthorized:false signCallback:nil];
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
        XCTAssert(error != nil);
        XCTAssert([error code] == 20304);

        [cardManager publishCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil completion:^(VSSCard * returnedCard, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(returnedCard != nil);

            NSError *err;
            VSSRawSignedModel *rawCard = [cardManager generateRawCardWithPrivateKey:keyPair.privateKey publicKey:keyPair.publicKey identity:identity previousCardId:nil extraFields:nil error:&err];
            XCTAssert(err == nil);
            VSSCard *card = [VSSCard parseWithCrypto:self.cardCrypto rawSignedModel:rawCard];
            XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
            
            [cardManager getCardWithId:card.identifier completion:^(VSSCard * returnedCard, NSError *error) {
                XCTAssert(error != nil);
                XCTAssert([error code] == 20304);
                
                [cardManager getCardWithId:card.identifier completion:^(VSSCard * returnedCard, NSError *error) {
                    XCTAssert(error == nil);
                    XCTAssert(returnedCard != nil);
                    
                    XCTAssert([self.utils isCardsEqualWithCard:card and:returnedCard]);
                    
                    [cardManager searchCardsWithIdentity:identity completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
                        XCTAssert(error != nil);
                        XCTAssert([error code] == 20304);
                        
                        [cardManager searchCardsWithIdentity:identity completion:^(NSArray<VSSCard *> * returnedCards, NSError *error) {
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
    
    [self waitForExpectationsWithTimeout:15. handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
