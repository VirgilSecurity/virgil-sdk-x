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

- (void)test001_createCard {
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
