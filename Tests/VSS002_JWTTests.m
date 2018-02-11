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
@import VirgilCryptoApiImpl;
@import VirgilCrypto;

#import "VSSTestsConst.h"

// static const NSTimeInterval timeout = 15.;

@interface VSS001_JWTTests : XCTestCase

@end

@implementation VSS001_JWTTests

- (void)test001_STC_24 {
    // XCTestExpectation *ex = [self expectationWithDescription:@"Jwt should return cash token, force reload"];
    NSTimeInterval ttl = 5;
    VSSCallbackJwtProvider *callbackJwtProvider = [[VSSCallbackJwtProvider alloc] initWithGetTokenCallback:^(void (^ completionHandler)(NSString* token, NSError* error)) {
        
        VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
        
        NSError *err;
        VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
        XCTAssert(err == nil);
        
        VSMVirgilAccessTokenSigner *signer = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:crypto];
        VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"id" accessTokenSigner:signer appId:@"app_id" ttl:ttl];
        
        NSString *identity = @"some_identity";
        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:&err];
        XCTAssert(err == nil);

        completionHandler([jwt stringRepresentation], err);
        return;
    }];
    XCTAssert([callbackJwtProvider token] == nil);

    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:nil operation:@"FIXME" forceReload:NO];
    [callbackJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil && jwt == [callbackJwtProvider token]);

        [callbackJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> cashedJwt, NSError *error) {
            XCTAssert(error == nil && cashedJwt != nil && cashedJwt == [callbackJwtProvider token] && cashedJwt == jwt);
            sleep(ttl);

            [callbackJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> newJwt1, NSError *error) {
                XCTAssert(error == nil && newJwt1 != nil && newJwt1 == [callbackJwtProvider token] && newJwt1 != cashedJwt);
                VSSTokenContext *tokenContextForceReload = [[VSSTokenContext alloc] initWithIdentity:nil operation:@"FIXME" forceReload:YES];

                [callbackJwtProvider getTokenWith:tokenContextForceReload completion:^(id<VSSAccessToken> newJwt2, NSError *error) {
                    XCTAssert(error == nil && newJwt2 != nil && newJwt2 == [callbackJwtProvider token] && newJwt2 != newJwt1);

                    // [ex fulfill];
                }];
            }];
        }];
    }];

//    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
//        if (error != nil)
//            XCTFail(@"Expectation failed: %@", error);
//    }];
}

-(void)test002_STC_28 {
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test_data" ofType:@"txt"];
    NSData *dicData = [[NSData alloc] initWithContentsOfFile:path];
    XCTAssert(dicData != nil);

    NSDictionary *testData = [NSJSONSerialization JSONObjectWithData:dicData options:kNilOptions error:&error];
    XCTAssert(error == nil);

    VSSJwt *jwt = [[VSSJwt alloc] initWithStringRepresentation:testData[@"STC-28.jwt"]];
    XCTAssert(jwt != nil);

    XCTAssert([jwt.headerContent.algorithm isEqualToString:testData[@"STC-28.jwt_algorithm"]]);
    XCTAssert([jwt.headerContent.contentType isEqualToString:testData[@"STC-28.jwt_content_type"]]);
    XCTAssert([jwt.headerContent.type isEqualToString:testData[@"STC-28.jwt_type"]]);
    XCTAssert([jwt.headerContent.keyIdentifier isEqualToString:testData[@"STC-28.jwt_api_key_id"]]);

    XCTAssert([jwt.bodyContent.identity isEqualToString:testData[@"STC-28.jwt_identity"]]);
    XCTAssert([jwt.bodyContent.appId isEqualToString:testData[@"STC-28.jwt_app_id"]]);
    NSString *issuedAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.issuedAt];
    XCTAssert([issuedAt isEqualToString:testData[@"STC-28.jwt_issued_at"]]);
    NSString *expiresAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.expiresAt];
    XCTAssert([expiresAt isEqualToString:testData[@"STC-28.jwt_expires_at"]]);
    XCTAssert(jwt.isExpired == true);

    NSData *data = [testData[@"STC-28.jwt_additional_data"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssert([jwt.bodyContent.additionalData isEqualToDictionary:dic]);
    
    XCTAssert([[[jwt signatureContent] base64EncodedStringWithOptions:0] isEqualToString:testData[@"STC-28.jwt_signature_base64"]]);
}

@end
