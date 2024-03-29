//
// Copyright (C) 2015-2021 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

#import "VSSTestBase.h"

static const NSTimeInterval timeout = 8.;

@interface VSS002_JWTTests : VSSTestBase

@end

@implementation VSS002_JWTTests

- (void)test001_STC_24 {
    XCTestExpectation *ex1 = [self expectationWithDescription:@"callbackJwtProvider should always return new token"];
    XCTestExpectation *ex2 = [self expectationWithDescription:@"JwtProvider throws if callback returns invalid token"];
    NSTimeInterval ttl = 5;
    VSSCallbackJwtProvider *callbackJwtProvider = [[VSSCallbackJwtProvider alloc] initWithGetTokenCallback:^(VSSTokenContext *tokenContext, void(^ completionHandler)(NSString* token, NSError* error)) {
        VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:YES error:nil];

        NSError *err;
        VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
        XCTAssert(err == nil);

        VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"key_id" crypto:crypto appId:@"app_id" ttl:ttl error:nil];

        NSString *identity = tokenContext.identity;
        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:&err];
        XCTAssert(err == nil);

        completionHandler([jwt stringRepresentation], err);
    }];

    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity" service:@"cards" operation:@"test" forceReload:NO];
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

- (void)test002_STC_37 {
    XCTestExpectation *ex = [self expectationWithDescription:@"ConstAccessTokenProvider should always return the same token regardless of the tokenContext"];

    NSError *err;
    VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:YES error:nil];
    VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
    XCTAssert(err == nil);

    NSTimeInterval ttl = 2;
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"key_id" crypto:crypto appId:@"app_id" ttl:ttl error:nil];
    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity1" service:@"cards" operation:@"test" forceReload:NO];
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

- (void)test003_STC_28 {
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Cards" ofType:@"json"];
    NSData *dicData = [[NSData alloc] initWithContentsOfFile:path];
    XCTAssert(dicData != nil);

    NSDictionary *testData = [NSJSONSerialization JSONObjectWithData:dicData options:kNilOptions error:&error];
    XCTAssert(error == nil);

    VSSJwt *jwt = [[VSSJwt alloc] initWithStringRepresentation:testData[@"STC-28.jwt"] error:&error];
    XCTAssert(error == nil && jwt != nil);

    XCTAssert([jwt.headerContent.algorithm isEqualToString:testData[@"STC-28.jwt_algorithm"]]);
    XCTAssert([jwt.headerContent.contentType isEqualToString:testData[@"STC-28.jwt_content_type"]]);
    XCTAssert([jwt.headerContent.type isEqualToString:testData[@"STC-28.jwt_type"]]);
    XCTAssert([jwt.headerContent.keyIdentifier isEqualToString:testData[@"STC-28.jwt_api_key_id"]]);

    XCTAssert([jwt.bodyContent.identity isEqualToString:testData[@"STC-28.jwt_identity"]]);
    XCTAssert([jwt.bodyContent.appId isEqualToString:testData[@"STC-28.jwt_app_id"]]);
    NSString *issuedAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.issuedAt.timeIntervalSince1970];
    XCTAssert([issuedAt isEqualToString:testData[@"STC-28.jwt_issued_at"]]);
    NSString *expiresAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.expiresAt.timeIntervalSince1970];
    XCTAssert([expiresAt isEqualToString:testData[@"STC-28.jwt_expires_at"]]);
    XCTAssert([jwt isExpiredWithDate:NSDate.date] == true);

    NSData *data = [testData[@"STC-28.jwt_additional_data"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssert([jwt.bodyContent.additionalData isEqualToDictionary:dic]);
    
    XCTAssert([[jwt.signatureContent.signature base64EncodedStringWithOptions:0] isEqualToString:testData[@"STC-28.jwt_signature_base64"]]);
}

- (void)test004_STC_29 {
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Cards" ofType:@"json"];
    NSData *dicData = [[NSData alloc] initWithContentsOfFile:path];
    XCTAssert(dicData != nil);

    NSDictionary *testData = [NSJSONSerialization JSONObjectWithData:dicData options:kNilOptions error:&error];
    XCTAssert(error == nil);

    VSSJwt *jwt = [[VSSJwt alloc] initWithStringRepresentation:testData[@"STC-29.jwt"] error:&error];
    XCTAssert(error == nil && jwt != nil);

    XCTAssert([jwt.headerContent.algorithm isEqualToString:testData[@"STC-29.jwt_algorithm"]]);
    XCTAssert([jwt.headerContent.contentType isEqualToString:testData[@"STC-29.jwt_content_type"]]);
    XCTAssert([jwt.headerContent.type isEqualToString:testData[@"STC-29.jwt_type"]]);
    XCTAssert([jwt.headerContent.keyIdentifier isEqualToString:testData[@"STC-29.jwt_api_key_id"]]);

    XCTAssert([jwt.bodyContent.identity isEqualToString:testData[@"STC-29.jwt_identity"]]);
    XCTAssert([jwt.bodyContent.appId isEqualToString:testData[@"STC-29.jwt_app_id"]]);
    NSString *issuedAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.issuedAt.timeIntervalSince1970];
    XCTAssert([issuedAt isEqualToString:testData[@"STC-29.jwt_issued_at"]]);
    NSString *expiresAt = [NSString stringWithFormat:@"%ld", (long)jwt.bodyContent.expiresAt.timeIntervalSince1970];
    XCTAssert([expiresAt isEqualToString:testData[@"STC-29.jwt_expires_at"]]);
    XCTAssert([jwt isExpiredWithDate:NSDate.date] == false);

    NSData *data = [testData[@"STC-29.jwt_additional_data"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssert([jwt.bodyContent.additionalData isEqualToDictionary:dic]);

    XCTAssert([[jwt.signatureContent.signature base64EncodedStringWithOptions:0] isEqualToString:testData[@"STC-29.jwt_signature_base64"]]);
}

- (void)test005_STC_38 {
    XCTestExpectation *ex = [self expectationWithDescription:@"cachingJwtProvider should cache token"];
    NSTimeInterval ttl = 10;
    VSSCachingJwtProvider *cachingJwtProvider = [[VSSCachingJwtProvider alloc] initWithInitialJwt:nil renewTokenCallback:^(VSSTokenContext *tokenContext, void(^completionHandler)(NSString* token, NSError* error)) {
        VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:YES error:nil];
        
        NSError *err;
        VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
        XCTAssert(err == nil);
        
        VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"key_id" crypto:crypto appId:@"app_id" ttl:ttl error:nil];
        
        NSString *identity = tokenContext.identity;
        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:&err];
        XCTAssert(err == nil);
        
        completionHandler([jwt stringRepresentation], err);
    }];
    
    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity" service:@"cards" operation:@"test" forceReload:NO];
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);
        
        [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> newJwt, NSError *error) {
            XCTAssert(error == nil && newJwt == jwt);
            sleep(ttl);
            
            [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> veryNewJwt, NSError *error) {
                XCTAssert(error == nil && veryNewJwt != nil && veryNewJwt != newJwt);
                
                [ex fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}
    
- (void)test006_STC_39 {
    NSTimeInterval ttl = 10;
    VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:YES error:nil];
    
    NSError *err;
    VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
    XCTAssert(err == nil);
    
    NSString *identity = @"some_identity";
    
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"key_id" crypto:crypto appId:@"app_id" ttl:ttl error:nil];
    
    NSInteger __block callCounter = 0;
    
    dispatch_queue_t queue = dispatch_queue_create("queue", 0);
    
    VSSCachingJwtProvider *cachingJwtProvider = [[VSSCachingJwtProvider alloc] initWithInitialJwt:nil renewTokenCallback:^(VSSTokenContext *tokenContext, void(^completionHandler)(NSString* token, NSError* error)) {
        
        dispatch_async(queue, ^{
            VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:nil];
            
            callCounter++;
            sleep(1);
            
            completionHandler([jwt stringRepresentation], nil);
        });
    }];
    
    id<VSSAccessToken> __block jwt1;
    id<VSSAccessToken> __block jwt2;
    
    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:identity service:@"cards" operation:@"test" forceReload:NO];
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);
        
        jwt1 = jwt;
    }];
    
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);
        
        jwt2 = jwt;
    }];
    
    sleep(5);
    
    XCTAssert(jwt1 == jwt2);
    XCTAssert(callCounter == 1);
}
    
- (void)test007_STC_40 {
    NSTimeInterval ttl = 10;
    VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:YES error:nil];
    
    NSError *err;
    VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
    XCTAssert(err == nil);
    
    NSString *identity = @"some_identity";
    
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"key_id" crypto:crypto appId:@"app_id" ttl:ttl error:nil];
    
    VSSJwt *initialJwt = [generator generateTokenWithIdentity:identity additionalData:nil error:nil];
    
    NSInteger __block callCounter = 0;
    
    VSSCachingJwtProvider *cachingJwtProvider = [[VSSCachingJwtProvider alloc] initWithInitialJwt:initialJwt renewTokenCallback:^(VSSTokenContext *tokenContext, void(^completionHandler)(NSString* token, NSError* error)) {

        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:nil];
        
        callCounter++;
        
        completionHandler([jwt stringRepresentation], nil);
    }];
    
    id<VSSAccessToken> __block jwt1;
    id<VSSAccessToken> __block jwt2;
    id<VSSAccessToken> __block jwt3;
    
    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:identity service:@"cards" operation:@"test" forceReload:NO];
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);
        
        jwt1 = jwt;
    }];
    
    sleep(3);
    
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);
        
        jwt2 = jwt;
    }];
    
    sleep(9);
    
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);
        
        jwt3 = jwt;
    }];
    
    XCTAssert(initialJwt == jwt1);
    XCTAssert(jwt1 == jwt2);
    XCTAssert(jwt2 != jwt3);
    XCTAssert(callCounter == 1);
}

- (void)test008_STC_43 {
    XCTestExpectation *ex = [self expectationWithDescription:@"CachingJwtProvider should reload token on forceReload = true"];
    NSTimeInterval ttl = 10;

    VSSCachingJwtProvider *cachingJwtProvider = [[VSSCachingJwtProvider alloc] initWithInitialJwt:nil renewTokenCallback:^(VSSTokenContext *tokenContext, void(^completionHandler)(NSString* token, NSError* error)) {
        VSMVirgilCrypto *crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSMKeyPairTypeEd25519 useSHA256Fingerprints:true error:nil];

        NSError *err;
        VSMVirgilKeyPair *keyPair = [crypto generateKeyPairAndReturnError:&err];
        XCTAssert(err == nil);

        VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:[keyPair privateKey] apiPublicKeyIdentifier:@"key_id" crypto:crypto appId:@"app_id" ttl:ttl error:nil];

        NSString *identity = tokenContext.identity;
        VSSJwt *jwt = [generator generateTokenWithIdentity:identity additionalData:nil error:&err];
        XCTAssert(err == nil);

        completionHandler([jwt stringRepresentation], err);
    }];

    VSSTokenContext *tokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity" service:@"cards" operation:@"test" forceReload:NO];
    [cachingJwtProvider getTokenWith:tokenContext completion:^(id<VSSAccessToken> jwt, NSError *error) {
        XCTAssert(error == nil && jwt != nil);

        VSSTokenContext *newTokenContext = [[VSSTokenContext alloc] initWithIdentity:@"some_identity" service:@"cards" operation:@"test" forceReload:YES];
        [cachingJwtProvider getTokenWith:newTokenContext completion:^(id<VSSAccessToken> newJwt, NSError *error) {
            XCTAssert(error == nil && newJwt != nil && newJwt != jwt);

            [ex fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

@end
