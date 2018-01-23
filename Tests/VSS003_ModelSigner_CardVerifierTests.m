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
@import VirgilCrypto;

#import "VSSTestsConst.h"

@interface VSS003_ModelSignerCardVerifierTests : XCTestCase

@end

@implementation VSS003_ModelSignerCardVerifierTests

- (void)test001 {
    VSCVirgilCrypto       *crypto     = [[VSCVirgilCrypto      alloc] init];
    VSCVirgilCardCrypto   *cardCrypto = [[VSCVirgilCardCrypto  alloc] init];
    VSSModelSigner        *signer     = [[VSSModelSigner       alloc] initWithCrypto:cardCrypto];
    
    VSCVirgilKeyPair *keyPair1 = [crypto generateKeyPair];
    
    // Test Utils
    int length = 2048;
    NSMutableData *data = [NSMutableData dataWithCapacity:length];
    for (unsigned int i = 0; i < length/4; ++i) {
        u_int32_t randomBits = arc4random();
        [data appendBytes:(void*)&randomBits length:4];
    }
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data signatures:nil];
    
    XCTAssert(rawCard.signatures.count == 0);
    
    NSError *error;
    [signer selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1 != nil);
    
    XCTAssert(signature1.snapshot == [[NSString alloc] init]);
    XCTAssert(signature1.signerType == VSSSignerTypeSelf && signature1.signature != [[NSData alloc] init]);
    
    NSData *fingerprint = [cardCrypto generateSHA256For:data error:&error];
    [crypto verifySignature:signature1.signature of:fingerprint with:keyPair1.publicKey error:&error];
    XCTAssert(error == nil);
    
    [signer selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
    
    error = nil;
    VSCVirgilKeyPair *keyPair2 = [crypto generateKeyPair];
    [signer signWithModel:rawCard id:@"test_id" type:VSSSignerTypeCustom privateKey:keyPair2.privateKey additionalData:nil error:&error];
    
    XCTAssert(rawCard.signatures.count == 2 && error == nil);
    
    VSSRawSignature *signature2 = rawCard.signatures[1];
    XCTAssert(signature2.snapshot == [[NSString alloc] init] && [signature2.signerId isEqualToString:@"test_id"]);
    XCTAssert(signature2.signerType == VSSSignerTypeCustom && signature2.signature != [[NSData alloc] init]);
    
    [crypto verifySignature:signature2.signature of:fingerprint with:keyPair2.publicKey error:&error];
    XCTAssert(error == nil);
    
    [signer signWithModel:rawCard id:@"test_id" type:VSSSignerTypeCustom privateKey:keyPair2.privateKey additionalData:nil error:&error];
    XCTAssert(error != nil);
}

-(void)test002_withAdditionalData {
    VSCVirgilCrypto       *crypto     = [[VSCVirgilCrypto      alloc] init];
    VSCVirgilCardCrypto   *cardCrypto = [[VSCVirgilCardCrypto  alloc] init];
    VSSModelSigner        *signer     = [[VSSModelSigner       alloc] initWithCrypto:cardCrypto];
    
    VSCVirgilKeyPair *keyPair1 = [crypto generateKeyPair];
    
    // Test Utils
    int length = 2048;
    NSMutableData *data = [NSMutableData dataWithCapacity:length];
    for (unsigned int i = 0; i < length/4; ++i) {
        u_int32_t randomBits = arc4random();
        [data appendBytes:(void*)&randomBits length:4];
    }
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:data signatures:nil];
    
    XCTAssert(rawCard.signatures.count == 0);
    
    NSError *error;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"data1" forKey:@"key1"];
    [dic setValue:@"data2" forKey:@"key2"];
    NSData *dataDic = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [signer selfSignWithModel:rawCard privateKey:keyPair1.privateKey additionalData:dataDic error:&error];
    
    XCTAssert(rawCard.signatures.count == 1 & error == nil);
    
    VSSRawSignature *signature1 = rawCard.signatures.firstObject;
    XCTAssert(signature1 != nil);

    XCTAssert(signature1.snapshot != [[NSString alloc] init]);
    // FIXME
    //XCTAssert(signature1.snapshot == [dataDic base64EncodedStringWithOptions:0]);
    XCTAssert(signature1.signerType == VSSSignerTypeSelf && signature1.signature != [[NSData alloc] init]);
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
