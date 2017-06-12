//
//  VSSAuthClient.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSAuthClient.h"
#import "NSObject+VSSUtils.h"
#import "VSSGetChallengeMessageHTTPRequest.h"
#import "VSSAuthAckHTTPRequest.h"
#import "VSSObtainTokenHTTPRequest.h"
#import "VSSRefreshTokenHTTPRequest.h"
#import "VSSVerifyTokenHTTPRequest.h"

static NSString *const kVSSAccessCodeGrantType = @"access_code";
static NSString *const kVSSRefreshTokenGrantType = @"refresh_token";

@implementation VSSAuthClient

#pragma mark - Lifecycle

- (instancetype)initWithAuthServiceConfig:(VSSAuthServiceConfig *)authServiceConfig {
    self = [super init];
    if (self) {
        _serviceConfig = [authServiceConfig copy];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithAuthServiceConfig:[[VSSAuthServiceConfig alloc] init]];
}

- (void)getChallengeMessageForVirgilCardWithId:(NSString *)virgilCardId completion:(void (^)(VSSChallengeMessageResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.serviceURL];
    VSSChallengeMessageRequest *request = [[VSSChallengeMessageRequest alloc] initWithOwnerVirgilCardId:virgilCardId];
    VSSGetChallengeMessageHTTPRequest *httpRequest = [[VSSGetChallengeMessageHTTPRequest alloc] initWithContext:context challengeMessageRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSGetChallengeMessageHTTPRequest *r = [request vss_as:[VSSGetChallengeMessageHTTPRequest class]];
            callback(r.challengeMessageResponse, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
}

- (void)ackChallengeMessageWithAuthGrantId:(NSString *)authGrantId encryptedMessage:(NSData *)encryptedMessage completion:(void (^)(NSString *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.serviceURL];
    VSSAuthAckRequest *request = [[VSSAuthAckRequest alloc] initWithEncryptedMesasge:encryptedMessage];
    VSSAuthAckHTTPRequest *httpRequest = [[VSSAuthAckHTTPRequest alloc] initWithContext:context authGrantId:authGrantId authAckRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSAuthAckHTTPRequest *r = [request vss_as:[VSSAuthAckHTTPRequest class]];
            callback(r.authAckResponse.code, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
}

- (void)obtainAccessTokenWithAccessCode:(NSString *)accessCode completion:(void (^)(VSSObtainTokenResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.serviceURL];
    VSSTokenRequest *request = [[VSSTokenRequest alloc] initWithGrantType:kVSSAccessCodeGrantType authCode:accessCode];
    VSSObtainTokenHTTPRequest *httpRequest = [[VSSObtainTokenHTTPRequest alloc] initWithContext:context tokenRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSObtainTokenHTTPRequest *r = [request vss_as:[VSSObtainTokenHTTPRequest class]];
            callback(r.tokenResponse, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken completion:(void (^)(VSSTokenResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.serviceURL];
    VSSRefreshTokenRequest *request = [[VSSRefreshTokenRequest alloc] initWithGrantType:kVSSRefreshTokenGrantType refreshToken:refreshToken];
    VSSRefreshTokenHTTPRequest *httpRequest = [[VSSRefreshTokenHTTPRequest alloc] initWithContext:context refreshTokenRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSRefreshTokenHTTPRequest *r = [request vss_as:[VSSRefreshTokenHTTPRequest class]];
            callback(r.tokenResponse, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
}

- (void)verifyAccessToken:(NSString *)accessToken completion:(void (^)(NSString *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.serviceURL];
    VSSVerifyTokenRequest *request = [[VSSVerifyTokenRequest alloc] initWithAccessToken:accessToken];
    VSSVerifyTokenHTTPRequest *httpRequest = [[VSSVerifyTokenHTTPRequest alloc] initWithContext:context verifyTokenRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSVerifyTokenHTTPRequest *r = [request vss_as:[VSSVerifyTokenHTTPRequest class]];
            callback(r.verifyTokenResponse.resourceOwnerVirgilCardId, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
}

@end
