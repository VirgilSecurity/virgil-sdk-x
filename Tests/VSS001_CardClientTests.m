//
//  VSS001_CardClientTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCrypto;

#import "VSSTestsConst.h"

@interface VSS001_CardClientTests : XCTestCase

@end

@implementation VSS001_CardClientTests

- (void)test001 {
    NSString *accessKey       = @"530fc95b222590e57008e4d43a9f7f589d303f214fba54df21c08457cd89935c";
    NSString *accessPublicKey = @"MCowBQYDK2VwAyEA2tzlPfxSgpUhJHYSEejrWDzC+HDc4QS9J/yhaAtOXrc=";
    NSString *appID           = @"5a672d7860ea24000197dc1d";
    
    VSSCardClient *cardClient = [[VSSCardClient alloc] initWithServiceUrl:nil connection:nil];
    VSCVirgilCrypto *crypto = [[VSCVirgilCrypto alloc] init];
    
//    FIXME cannot import
//    VSCVirgilPrivateKeyExporter *exporter = [[VSCVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:crypto password:nil];
//
//    NSData *privKey = [[NSData alloc] initWithBase64EncodedString:accessKey options:0];
//    VSCVirgilPrivateKey *privateKey = (VSCVirgilPrivateKey *)[exporter importPrivateKeyFrom:privKey error:&error];
//    XCTAssert(error == nil);
    
    NSError *error;
    VSCVirgilKeyPair *keyPair = [crypto generateKeyPair];
    VSCVirgilPrivateKey *incorrectPrivateKey = keyPair.privateKey;
    
    VSCVirgilAccessTokenSigner *signer = [[VSCVirgilAccessTokenSigner alloc] init];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:incorrectPrivateKey apiPublicKeyIdentifier:accessPublicKey accessTokenSigner:signer appId:appID ttl:0];
    
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:@"tokenIdentity" additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    NSString *strToken = [jwtToken stringRepresentationAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *rawCard = [cardClient getCardWithId:@"cardId" token:strToken error:&error];

    XCTAssert(error != nil);
    
    
//    VSCVirgilCrypto *crypto = [[VSCVirgilCrypto alloc] init];
//    VSSCardManagerParams *params = [[VSSCardManagerParams alloc] initWithCrypto:crypto validator:nil];
//
//    VSSTestsConst *consts = [[VSSTestsConst alloc] init];
//
//    params.apiUrl = consts.cardsServiceURL;
//
//    VSSCardManager *cardManager = [[VSSCardManager alloc] initWithParams:params];
//
//    NSError *err;
//    NSString *identity = [[NSUUID alloc] init].UUIDString;
//
//    VSCVirgilKeyPair *keyPair = [crypto generateKeyPair];
//
//    VSSCSRParams *csrParams = [[VSSCSRParams alloc] initWithIdentity:identity publicKey:keyPair.publicKey privateKey:keyPair.privateKey];
//
//    VSSCSR *csr = [VSSCSR generateWithCrypto:crypto params:csrParams error:&err];
//    XCTAssert(err == nil);
//
//    VSSCard *card = [cardManager publishCardWithCsr:csr error:&err];
//    XCTAssert(card != nil && err == nil);
}

@end
