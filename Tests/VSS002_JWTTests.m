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

static const NSTimeInterval timeout = 8.;

@interface VSS002_JWTTests : XCTestCase

@end

@implementation VSS002_JWTTests

- (void)test001_STC_24 {
    XCTestExpectation *ex1 = [self expectationWithDescription:@"callbackJwtProvider should always return new token"];
    XCTestExpectation *ex2 = [self expectationWithDescription:@"JwtProvider throws if callback returns invalid token"];
    NSTimeInterval ttl = 5;
    VSSCallbackJwtProvider *callbackJwtProvider = [[VSSCallbackJwtProvider alloc] initWithGetTokenCallback:^(VSSTokenContext *tokenContext, void(^ completionHandler)(NSString* token, NSError* error)) {
        VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];

        NSError *err;
        VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
        XCTAssert(err == nil);

        VSMVirgilAccessTokenSigner *signer = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:crypto];
        VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"id" accessTokenSigner:signer appId:@"app_id" ttl:ttl];

        NSString *identity = tokenContext.identity;
        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:&err];
        XCTAssert(err == nil);

        completionHandler([jwt stringRepresentation], err);
    }];

    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity" operation:@"test" forceReload:NO];
    [callbackJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);

        [callbackJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> newJwt, NSError *error) {
            XCTAssert(error == nil && newJwt != nil && newJwt != jwt);
            sleep(ttl);

            [ex1 fulfill];
        }];
    }];

    VSSCallbackJwtProvider *callbackInvalidJwtProvider = [[VSSCallbackJwtProvider alloc] initWithGetTokenCallback:^(VSSTokenContext *tokenContext, void(^ completionHandler)(NSString* token, NSError* error)) {
        completionHandler(@"invalid-token", nil);
    }];

    [callbackInvalidJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error != nil && jwt == nil);

        [ex2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test002_STC_37 {
    XCTestExpectation *ex = [self expectationWithDescription:@"ConstAccessTokenProvider should always return the same token regardless of the tokenContext"];

    NSError *err;
    VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
    XCTAssert(err == nil);

    NSTimeInterval ttl = 2;
    VSMVirgilAccessTokenSigner *signer = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:crypto];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"id" accessTokenSigner:signer appId:@"app_id" ttl:ttl];
    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity1" operation:@"test" forceReload:NO];
    VSSJwt *jwt = [generator generateTokenWithIdentity:@"some_identity2" additionalData:nil error:&err];
    XCTAssert(err == nil);

    VSSConstAccessTokenProvider *constProvider = [[VSSConstAccessTokenProvider alloc] initWithAccessToken:jwt];
    [constProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt1, NSError *error) {
        XCTAssert(jwt1 != nil);
        [constProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt2, NSError *error) {
            XCTAssert(jwt2 != nil);
            XCTAssert(jwt1 == jwt2);

            [ex fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

-(void)test003_STC_28 {
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

-(void)test004_STC_29 {
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test_data" ofType:@"txt"];
    NSData *dicData = [[NSData alloc] initWithContentsOfFile:path];
    XCTAssert(dicData != nil);

    NSDictionary *testData = [NSJSONSerialization JSONObjectWithData:dicData options:kNilOptions error:&error];
    XCTAssert(error == nil);

    VSSJwt *jwt = [[VSSJwt alloc] initWithStringRepresentation:testData[@"STC-29.jwt"]];
    XCTAssert(jwt != nil);

    XCTAssert([jwt.headerContent.algorithm isEqualToString:testData[@"STC-29.jwt_algorithm"]]);
    XCTAssert([jwt.headerContent.contentType isEqualToString:testData[@"STC-29.jwt_content_type"]]);
    XCTAssert([jwt.headerContent.type isEqualToString:testData[@"STC-29.jwt_type"]]);
    XCTAssert([jwt.headerContent.keyIdentifier isEqualToString:testData[@"STC-29.jwt_api_key_id"]]);

    XCTAssert([jwt.bodyContent.identity isEqualToString:testData[@"STC-29.jwt_identity"]]);
    XCTAssert([jwt.bodyContent.appId isEqualToString:testData[@"STC-29.jwt_app_id"]]);
    NSString *issuedAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.issuedAt];
    XCTAssert([issuedAt isEqualToString:testData[@"STC-29.jwt_issued_at"]]);
    NSString *expiresAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.expiresAt];
    XCTAssert([expiresAt isEqualToString:testData[@"STC-29.jwt_expires_at"]]);
    XCTAssert(jwt.isExpired == false);

    NSData *data = [testData[@"STC-29.jwt_additional_data"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssert([jwt.bodyContent.additionalData isEqualToDictionary:dic]);

    XCTAssert([[[jwt signatureContent] base64EncodedStringWithOptions:0] isEqualToString:testData[@"STC-29.jwt_signature_base64"]]);
}

@end
