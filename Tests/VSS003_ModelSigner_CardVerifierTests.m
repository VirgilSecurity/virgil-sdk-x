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

@interface VSS003_ModelSignerCardVerifierTests : XCTestCase

@property (nonatomic) VSSTestsConst       * consts;
@property (nonatomic) VSMVirgilCrypto     * crypto;
@property (nonatomic) VSMVirgilCardCrypto * cardCrypto;
@property (nonatomic) VSSTestUtils        * utils;
@property (nonatomic) VSSCardClient       * cardClient;

@end

@implementation VSS003_ModelSignerCardVerifierTests

- (void)setUp {
    [super setUp];
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    self.cardCrypto = [[VSMVirgilCardCrypto alloc] initWithVirgilCrypto:self.crypto];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL connection:nil];
}

- (void)test001 {
    VSSModelSigner *signer     = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    
    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    NSData *data = [self.utils getRandomData];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data signatures:nil];
    XCTAssert(rawCard.signatures.count == 0);
    
    [signer selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1.snapshot == nil);
    XCTAssert([signature1.signerType isEqualToString:@"self"] && signature1.signature != [[NSData alloc] init]);
    
    NSData *fingerprint = [self.cardCrypto generateSHA256For:data error:&error];
    [self.crypto verifySignature:signature1.signature of:fingerprint with:keyPair1.publicKey error:&error];
    XCTAssert(error == nil);
    
    [signer selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
    error = nil;
    
    VSMVirgilKeyPair *keyPair2 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    [signer signWithModel:rawCard id:@"test_id" type:VSSSignerTypeExtra privateKey:keyPair2.privateKey additionalData:nil error:&error];
    XCTAssert(rawCard.signatures.count == 2 && error == nil);
    
    VSSRawSignature *signature2 = rawCard.signatures[1];
    XCTAssert(signature2.snapshot == nil && [signature2.signerId isEqualToString:@"test_id"]);
    XCTAssert([signature2.signerType isEqualToString:@"extra"] && signature2.signature != [[NSData alloc] init]);
    
    [self.crypto verifySignature:signature2.signature of:fingerprint with:keyPair2.publicKey error:&error];
    XCTAssert(error == nil);
    
    [signer signWithModel:rawCard id:@"test_id" type:VSSSignerTypeExtra privateKey:keyPair2.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
}

-(void)test002_withAdditionalData {
    VSSModelSigner *signer     = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    
    NSError *error;
    VSMVirgilKeyPair *keyPair1 = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *data = [self.utils getRandomData];
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data signatures:nil];
    XCTAssert(rawCard.signatures.count == 0);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];
    NSData *dataDic = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    [signer selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:dataDic error:&error];
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1 != nil);
    XCTAssert([signature1.snapshot isEqualToString:[dataDic base64EncodedStringWithOptions:0]]);
    XCTAssert([signature1.signerType isEqualToString:@"self"]);
    XCTAssert(signature1.signature != [[NSData alloc] init]);
}

//    NSData *publicKey1 = [crypto exportVirgilPublicKey:keyPair1.publicKey error:&error];
//    XCTAssert(error == nil);
//
//    VSSVerifierCredentials *verCreds = [[VSSVerifierCredentials alloc] initWithId:signature.signerId publicKey:publicKey1];
//    NSArray *credentials = [NSArray array];
//    credentials = [credentials arrayByAddingObject:verCreds];
//    VSSWhiteList *whitelist = [[VSSWhiteList alloc] initWithVerifiersCredentials:credentials];
//    NSArray *whitelists = [NSArray array];
//    whitelists = [whitelists arrayByAddingObject:whitelist];
//    VSSVirgilCardVerifier *verifier   = [[VSSVirgilCardVerifier alloc] initWithCrypto:cardCrypto whiteLists:whitelists];

@end
