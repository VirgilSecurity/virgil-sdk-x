//
//  VSS004_CrossCompatibilityTests.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/24/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCryptoApiImpl;
@import VirgilCrypto;

#import "VSSTestsConst.h"
#import "VSSTestUtils.h"

@interface VSS004_CrossCompatibilityTests : XCTestCase

@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSMVirgilCardCrypto *cardCrypto;
@property (nonatomic) VSSTestUtils *utils;
@property (nonatomic) VSSCardClient *cardClient;
@property (nonatomic) VSSModelSigner *modelSigner;
@property (nonatomic) VSSVirgilCardVerifier *verifier;
@property (nonatomic) NSDictionary *testData;

@end

@implementation VSS004_CrossCompatibilityTests

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    self.cardCrypto = [[VSMVirgilCardCrypto alloc] initWithVirgilCrypto:self.crypto];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.modelSigner = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    self.verifier = [[VSSVirgilCardVerifier alloc] initWithCrypto:self.cardCrypto whiteLists:[[NSArray alloc] init]];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL];
    
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

- (void)test001_STC_1 {
    NSError *error;
    NSString *rawCardString = self.testData[@"STC-1.as_string"];
    XCTAssert(rawCardString != nil);
    
    VSSRawSignedModel *rawCard1 = [[VSSRawSignedModel alloc] initWithString:rawCardString];
    XCTAssert(rawCard1 != nil);
    
    VSSRawCardContent *cardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard1.contentSnapshot];
    XCTAssert(cardContent1 != nil);
    
    XCTAssert([cardContent1.identity isEqualToString:@"test"]);
    XCTAssert([cardContent1.publicKey isEqualToString:@"MCowBQYDK2VwAyEA6d9bQQFuEnU8vSmx9fDo0Wxec42JdNg4VR4FOr4/BUk="]);
    XCTAssert([cardContent1.version isEqualToString:@"5.0"]);
    XCTAssert(cardContent1.createdAt == 1515686245);
    XCTAssert(cardContent1.previousCardId == nil);
    XCTAssert(rawCard1.signatures.count == 0);
    

    NSData *rawCardDic = [self.testData[@"STC-1.as_json"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert(rawCardDic != nil);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rawCardDic options:kNilOptions error:nil];
    XCTAssert(dic != nil);
    
    VSSRawSignedModel *rawCard2 = [[VSSRawSignedModel alloc] initWithJson:dic];
    XCTAssert(rawCard2 != nil);
    
    VSSRawCardContent *cardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard2.contentSnapshot];
    XCTAssert(cardContent2 != nil);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:cardContent1 and:cardContent2]);
    XCTAssert(rawCard2.signatures.count == 0);
    
// FIXME exported json compatibility
    NSData *snapshot1 = [cardContent1 snapshot];
    XCTAssert(error == nil && snapshot1 != nil);
    
    VSSRawSignedModel *newRawCard1 = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot1 signatures:rawCard1.signatures];
    XCTAssert(newRawCard1 != nil);
    
    NSString *exportedRawCardString = [rawCard1 exportAsStringAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *newImportedRawCard1 = [[VSSRawSignedModel alloc] initWithString:exportedRawCardString];
    XCTAssert(newImportedRawCard1 != nil);
    
    VSSRawCardContent *newCardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:newImportedRawCard1.contentSnapshot];
    XCTAssert(newCardContent1 != nil);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:newCardContent1 and:cardContent1]);
    XCTAssert(newImportedRawCard1.signatures.count == 0);
    
    NSDictionary *exportedRawCardJson = [newRawCard1 exportAsJsonAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *newImportedRawCard2 = [[VSSRawSignedModel alloc] initWithJson:exportedRawCardJson];
    XCTAssert(newImportedRawCard2 != nil);
    
    VSSRawCardContent *newCardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:newImportedRawCard2.contentSnapshot];
    XCTAssert(newCardContent2 != nil);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:newCardContent2 and:cardContent2]);
    XCTAssert(newImportedRawCard2.signatures.count == 0);
    
    XCTAssert(exportedRawCardJson[@"previous_card_id"] == nil);
}

- (void)test002_STC_2 {
    NSError *error;
    NSString *rawCardString = self.testData[@"STC-2.as_string"];
    XCTAssert(rawCardString != nil);
    NSLog(@"Message == %@", rawCardString);
    
    VSSRawSignedModel *rawCard1 = [[VSSRawSignedModel alloc] initWithString:rawCardString];
    XCTAssert(rawCard1 != nil);
    
    VSSRawCardContent *cardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard1.contentSnapshot];
    XCTAssert(cardContent1 != nil);
    
    XCTAssert([cardContent1.identity isEqualToString:@"test"]);
    XCTAssert([cardContent1.publicKey isEqualToString:@"MCowBQYDK2VwAyEA6d9bQQFuEnU8vSmx9fDo0Wxec42JdNg4VR4FOr4/BUk="]);
    XCTAssert([cardContent1.version isEqualToString:@"5.0"]);
    XCTAssert(cardContent1.createdAt == 1515686245);
    XCTAssert([cardContent1.previousCardId isEqualToString:@"a666318071274adb738af3f67b8c7ec29d954de2cabfd71a942e6ea38e59fff9"]);
    XCTAssert(rawCard1.signatures.count == 3);
    
    for (VSSRawSignature* signature in rawCard1.signatures) {
        if ([signature.signer isEqualToString:@"self"]) {
            XCTAssert([signature.signature isEqualToString:@"MFEwDQYJYIZIAWUDBAIDBQAEQNXguibY1cDCfnuJhTK+jX/Qv6v5i5TzqQs3e1fWlbisdUWYh+s10gsLkhf83wOqrm8ZXUCpjgkJn83TDaKYZQ8="]);
            XCTAssert(signature.snapshot == nil);
        } else if ([signature.signer isEqualToString:@"virgil"]) {
            XCTAssert([signature.signature isEqualToString:@"MFEwDQYJYIZIAWUDBAIDBQAEQNXguibY1cDCfnuJhTK+jX/Qv6v5i5TzqQs3e1fWlbisdUWYh+s10gsLkhf83wOqrm8ZXUCpjgkJn83TDaKYZQ8="]);
            XCTAssert(signature.snapshot == nil);
        } else if ([signature.signer isEqualToString:@"extra"]) {
            XCTAssert([signature.signature isEqualToString:@"MFEwDQYJYIZIAWUDBAIDBQAEQAAJD/9HE6iJwPHXuws+WBBUeG6HXB0eJcxojz9DtElJMPkkDxktgv/pBiBTkES3CAXfAtGS0rkvQL/OkjdCZwE="]);
            XCTAssert(signature.snapshot == nil);
        }
    }
    
    NSData *rawCardDic = [self.testData[@"STC-2.as_json"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert(rawCardDic != nil);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rawCardDic options:kNilOptions error:nil];
    XCTAssert(dic != nil);
    
    VSSRawSignedModel *rawCard2 = [[VSSRawSignedModel alloc] initWithJson:dic];
    XCTAssert(rawCard2 != nil);
    
    VSSRawCardContent *cardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard2.contentSnapshot];
    XCTAssert(cardContent2 != nil);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:cardContent1 and:cardContent2]);
    XCTAssert(rawCard2.signatures.count == 3);
    
    XCTAssert([self.utils isRawSignaturesEqualWithSignatures:rawCard1.signatures and:rawCard2.signatures]);
    
    // FIXME exported json compatibility
    NSData *snapshot1 = [cardContent1 snapshot];
    XCTAssert(error == nil && snapshot1 != nil);
    
    VSSRawSignedModel *newRawCard1 = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot1 signatures:rawCard1.signatures];
    XCTAssert(newRawCard1 != nil);
    
    NSString *exportedRawCardString = [rawCard1 exportAsStringAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *newImportedRawCard1 = [[VSSRawSignedModel alloc] initWithString:exportedRawCardString];
    XCTAssert(newImportedRawCard1 != nil);
    
    VSSRawCardContent *newCardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:newImportedRawCard1.contentSnapshot];
    XCTAssert(newCardContent1 != nil);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:newCardContent1 and:cardContent1]);
    XCTAssert(newImportedRawCard1.signatures.count == 3);
    
    XCTAssert([self.utils isRawSignaturesEqualWithSignatures:rawCard1.signatures and:newImportedRawCard1.signatures]);
    
    NSDictionary *exportedRawCardJson = [newRawCard1 exportAsJsonAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *newImportedRawCard2 = [[VSSRawSignedModel alloc] initWithJson:exportedRawCardJson];
    XCTAssert(newImportedRawCard2 != nil);
    
    VSSRawCardContent *newCardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:newImportedRawCard2.contentSnapshot];
    XCTAssert(newCardContent2 != nil);
    
    XCTAssert([self.utils isRawCardContentEqualWithContent:newCardContent2 and:cardContent2]);
    XCTAssert(newImportedRawCard2.signatures.count == 3);
    
    XCTAssert([self.utils isRawSignaturesEqualWithSignatures:rawCard1.signatures and:newImportedRawCard2.signatures]);
    
    XCTAssert(exportedRawCardJson[@"previous_card_id"] == nil);
}

-(void)test003_STC_3 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *rawCardString = self.testData[@"STC-3.as_string"];
    XCTAssert(rawCardString != nil);
 
    VSSCard *card1 = [cardManager importCardWithString:rawCardString];
    XCTAssert(card1 != nil);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:11];
    [comps setMonth:1];
    [comps setYear:2018];
    [comps setHour:17];         //???
    [comps setMinute:57];
    [comps setSecond:25];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    XCTAssert([card1.identifier isEqualToString:self.testData[@"STC-3.card_id"]]);
    XCTAssert([card1.identity isEqualToString:@"test"]);
    XCTAssert( card1.publicKey != nil);
    XCTAssert([[[self.crypto exportPublicKey:(VSMVirgilPublicKey *)card1.publicKey] base64EncodedStringWithOptions:0] isEqualToString:self.testData[@"STC-3.public_key_base64"]]);
    XCTAssert([card1.version isEqualToString:@"5.0"]);
    XCTAssert(card1.previousCard == nil);
    XCTAssert(card1.previousCardId == nil);
    XCTAssert(card1.signatures.count == 0);
    XCTAssert([card1.createdAt isEqualToDate:date]);
    
    NSData *rawCardDic = [self.testData[@"STC-3.as_json"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert(rawCardDic != nil);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rawCardDic options:kNilOptions error:nil];
    XCTAssert(dic != nil);
    
    VSSCard *card2 = [cardManager importCardWithJson:dic];
    XCTAssert(card2 != nil);
    
    [self.utils isCardsEqualWithCard:card1 and:card2];
    
    NSString *exportedCardString = [cardManager exportAsStringWithCard:card1 error:&error];
    XCTAssert(error == nil);
    
    VSSCard *newImportedCard1 = [cardManager importCardWithString:exportedCardString];
    XCTAssert(newImportedCard1 != nil);

    XCTAssert([self.utils isCardsEqualWithCard:card1 and:newImportedCard1]);
    
    NSDictionary *exportedCardJson = [cardManager exportAsJsonWithCard:card2 error:&error];
    XCTAssert(error == nil);
    
    VSSCard *newImportedCard2 = [cardManager importCardWithJson:exportedCardJson];
    XCTAssert(newImportedCard2 != nil);
    XCTAssert([self.utils isCardsEqualWithCard:card2 and:newImportedCard2]);
}

-(void)test004_STC_4 {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    VSSGeneratorJwtProvider *generator = [self.utils getGeneratorJwtProviderWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithCrypto:self.cardCrypto accessTokenProvider: generator modelSigner:self.modelSigner cardClient:self.cardClient cardVerifier:self.verifier signCallback:nil];
    
    NSString *rawCardString = self.testData[@"STC-4.as_string"];
    XCTAssert(rawCardString != nil);
    
    VSSCard *card1 = [cardManager importCardWithString:rawCardString];
    XCTAssert(card1 != nil);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:11];
    [comps setMonth:1];
    [comps setYear:2018];
    [comps setHour:17];         //???
    [comps setMinute:57];
    [comps setSecond:25];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    XCTAssert([card1.identifier isEqualToString:self.testData[@"STC-4.card_id"]]);
    XCTAssert([card1.identity isEqualToString:@"test"]);
    XCTAssert([[[self.crypto exportPublicKey:(VSMVirgilPublicKey *)card1.publicKey] base64EncodedStringWithOptions:0] isEqualToString:self.testData[@"STC-4.public_key_base64"]]);
    XCTAssert([card1.version isEqualToString:@"5.0"]);
    XCTAssert(card1.previousCard == nil);
    XCTAssert(card1.previousCardId == nil);
    XCTAssert(card1.signatures.count == 3);
    XCTAssert([card1.createdAt isEqualToDate:date]);
    
    for (VSSCardSignature* signature in card1.signatures) {
        if ([signature.signer isEqualToString:@"self"]) {
            XCTAssert([[signature.signature base64EncodedStringWithOptions:0] isEqualToString:self.testData[@"STC-4.signature_self_base64"]]);
            XCTAssert(signature.snapshot == [[NSData alloc] init]);
        } else if ([signature.signer isEqualToString:@"virgil"]) {
            XCTAssert([[signature.signature base64EncodedStringWithOptions:0] isEqualToString:self.testData[@"STC-4.signature_virgil_base64"]]);
            XCTAssert(signature.snapshot == [[NSData alloc] init]);
        } else if ([signature.signer isEqualToString:@"extra"]) {
            XCTAssert([[signature.signature base64EncodedStringWithOptions:0] isEqualToString:self.testData[@"STC-4.signature_extra_base64"]]);
            XCTAssert(signature.snapshot == [[NSData alloc] init]);
        }
    }
    
    NSData *rawCardDic = [self.testData[@"STC-4.as_json"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert(rawCardDic != nil);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rawCardDic options:kNilOptions error:nil];
    XCTAssert(dic != nil);
    
    VSSCard *card2 = [cardManager importCardWithJson:dic];
    XCTAssert(card2 != nil);
    XCTAssert([self.utils isCardsEqualWithCard:card1 and:card2]);
    XCTAssert([self.utils isCardSignaturesEqualWithSignatures:card1.signatures and:card2.signatures]);
    
    
    NSString *exportedCardString = [cardManager exportAsStringWithCard:card1 error:&error];
    XCTAssert(error == nil);
    
    VSSCard *newImportedCard1 = [cardManager importCardWithString:exportedCardString];
    XCTAssert(newImportedCard1 != nil);
    XCTAssert([self.utils isCardsEqualWithCard:card1 and:newImportedCard1]);
    XCTAssert([self.utils isCardSignaturesEqualWithSignatures:card1.signatures and:newImportedCard1.signatures]);
    
    NSDictionary *exportedCardJson = [cardManager exportAsJsonWithCard:card2 error:&error];
    XCTAssert(error == nil);
    
    VSSCard *newImportedCard2 = [cardManager importCardWithJson:exportedCardJson];
    XCTAssert(newImportedCard2 != nil);
    XCTAssert([self.utils isCardsEqualWithCard:card2 and:newImportedCard2]);
    XCTAssert([self.utils isCardSignaturesEqualWithSignatures:card1.signatures and:newImportedCard2.signatures]);
}

-(void)test005_STC_22 {
    NSError *error;
    VSMVirgilAccessTokenSigner *signer = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:self.crypto];
    NSData *publicKeyBase64 = [[NSData alloc] initWithBase64EncodedString:self.testData[@"STC-22.api_public_key_base64"] options:0];
    VSMVirgilPublicKey *publicKey = [self.crypto importPublicKeyFrom:publicKeyBase64 error:&error];
    XCTAssert(error == nil);
    
    VSSJwtVerifier *verifier = [[VSSJwtVerifier alloc] initWithApiPublicKey:publicKey apiPublicKeyIdentifier:self.testData[@"STC-22.api_key_id"] accessTokenSigner:signer];
    
    VSSJwt *jwt = [[VSSJwt alloc] initWithJwtToken:self.testData[@"STC-22.jwt"]];
    XCTAssert(jwt != nil);
    
    XCTAssert([jwt.headerContent.algorithm isEqualToString:@"VEDS512"]);
    XCTAssert([jwt.headerContent.contentType isEqualToString:@"virgil-jwt;v=1"]);
    XCTAssert([jwt.headerContent.type isEqualToString:@"JWT"]);
    XCTAssert([jwt.headerContent.keyIdentifier isEqualToString:@"7dc94e254f589521e045d2f95520180fabe8bf36141fbf3fd0ff89d6e4f9950de5a7c4559d3b96d0e45272f01f94c3eb5fc889913e33c1f136d12b882019e313"]);
    
    XCTAssert([jwt.bodyContent.identity isEqualToString:@"some_identity"]);
    XCTAssert([jwt.bodyContent.appId isEqualToString:@"0f3b26e2114dce3faa1cc4917fc0a54955dab1ea0950239fde60d68dca400b3e"]);
    XCTAssert(jwt.bodyContent.issuedAt == 1517922141);
    XCTAssert(jwt.bodyContent.expiresAt == 1517922741);
    XCTAssert(jwt.isExpired == true);
    
    XCTAssert([jwt.stringRepresentation isEqualToString:self.testData[@"STC-22.jwt"]]);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"some_username" forKey:@"username"];
    XCTAssert([jwt.bodyContent.additionalData isEqualToDictionary:dic]);
    
    XCTAssert([verifier verifyTokenWithJwtToken:jwt]);
}

-(void)test006_STC_23 {
    NSError *error;
    
    self.continueAfterFailure = NO;
    VSMVirgilAccessTokenSigner *signer = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:self.crypto];
    NSData *publicKeyBase64 = [[NSData alloc] initWithBase64EncodedString:self.testData[@"STC-23.api_public_key_base64"] options:0];
    VSMVirgilPublicKey *publicKey = [self.crypto importPublicKeyFrom:publicKeyBase64 error:&error];
    XCTAssert(error == nil);
    VSSJwtVerifier *verifier = [[VSSJwtVerifier alloc] initWithApiPublicKey:publicKey apiPublicKeyIdentifier:self.testData[@"STC-23.api_key_id"] accessTokenSigner:signer];
    
    NSString *apiKeyStringBase64 = self.testData[@"STC-23.api_private_key_base64"];
    NSData *apiKeyDataBase64 = [[NSData alloc] initWithBase64EncodedString:apiKeyStringBase64 options:0];
    VSMVirgilPrivateKeyExporter *exporter = [[VSMVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:self.crypto password:nil];
    VSMVirgilPrivateKey *privateKey = (VSMVirgilPrivateKey *)[exporter importPrivateKeyFrom:apiKeyDataBase64 error:&error];
    XCTAssert(error == nil);
    
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:self.testData[@"STC-23.api_key_id"] accessTokenSigner:signer appId:self.testData[@"STC-23.app_id"] ttl:1000];
    
    NSString *identity = @"some_identity";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"some_username" forKey:@"username"];
    VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:dic error:&error];
    XCTAssert(error == nil);
    XCTAssert(jwt != nil);
    
    VSSJwt *jwt22 = [[VSSJwt alloc] initWithJwtToken:self.testData[@"STC-22.jwt"]];
    XCTAssert(jwt22 != nil);
    
    XCTAssert([jwt.headerContent.algorithm isEqualToString:@"VEDS512"]);
    XCTAssert([jwt.headerContent.contentType isEqualToString:@"virgil-jwt;v=1"]);
    XCTAssert([jwt.headerContent.type isEqualToString:@"JWT"]);
    XCTAssert([jwt.headerContent.keyIdentifier isEqualToString:jwt22.headerContent.keyIdentifier]);
    
    XCTAssert([jwt.bodyContent.identity isEqualToString:jwt22.bodyContent.identity]);
    XCTAssert([jwt.bodyContent.appId isEqualToString:jwt22.bodyContent.appId]);
    XCTAssert(jwt.isExpired == false);
    
    XCTAssert([jwt.bodyContent.additionalData isEqualToDictionary:dic]);
    
    XCTAssert([verifier verifyTokenWithJwtToken:jwt]);
}


@end
