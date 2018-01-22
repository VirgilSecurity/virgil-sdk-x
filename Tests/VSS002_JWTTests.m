//
//  VSS002_JWTTests.m
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

@interface VSS001_JWTTests : XCTestCase

@end

@implementation VSS001_JWTTests

- (void)test001 {
    NSTimeInterval ttl = 5;
    VSSCallbackJwtProvider *callbackJwtProvider = [[VSSCallbackJwtProvider alloc] initWithGetTokenCallback:^NSString*(void){
        VSCVirgilCrypto *crypto = [[VSCVirgilCrypto alloc] init];
        VSCVirgilKeyPair *keyPair = [crypto generateKeyPair];
        VSCVirgilAccessTokenSigner *signer = [[VSCVirgilAccessTokenSigner alloc] init];
        VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"id" accessTokenSigner:signer appId:@"app_id" ttl:ttl];
        
        NSError *error;
        NSString *identity = [[NSUUID alloc] init].UUIDString;
        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:&error];
        
        XCTAssert(error == nil);
        
        return [jwt stringRepresentationAndReturnError:&error];
    }];
    NSError *error;
    
    XCTAssert([callbackJwtProvider token] == nil);
    
    VSSJwt *jwt = (VSSJwt *)[callbackJwtProvider getTokenWithForceReload:NO error:&error];
    
    XCTAssert(error == nil && jwt != nil && jwt == [callbackJwtProvider token]);
    
    VSSJwt *cashedJwt = (VSSJwt *)[callbackJwtProvider getTokenWithForceReload:NO error:&error];
    
    XCTAssert(error == nil && cashedJwt != nil && cashedJwt == [callbackJwtProvider token] && cashedJwt == jwt);
    
    sleep(ttl);
    
    VSSJwt *newJwt1 = (VSSJwt *)[callbackJwtProvider getTokenWithForceReload:NO error:&error];
    
    XCTAssert(error == nil && newJwt1 != nil && newJwt1 == [callbackJwtProvider token] && newJwt1 != cashedJwt);
    
    VSSJwt *newJwt2 = (VSSJwt *)[callbackJwtProvider getTokenWithForceReload:YES error:&error];
    
    XCTAssert(error == nil && newJwt2 != nil && newJwt2 == [callbackJwtProvider token] && newJwt2 != newJwt1);
}

@end
