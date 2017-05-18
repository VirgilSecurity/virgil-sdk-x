//
//  VSSClient.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSClient.h"
#import "NSObject+VSSUtils.h"

#import "VSSSearchCardsCriteria.h"
#import "VSSServiceConfig.h"

#import "VSSCreateCardHTTPRequest.h"
#import "VSSSearchCardsHTTPRequest.h"
#import "VSSGetCardHTTPRequest.h"
#import "VSSCreateCardRelationHTTPRequest.h"
#import "VSSRemoveCardRelationHTTPRequest.h"
#import "VSSRevokeCardHTTPRequest.h"
#import "VSSCardResponsePrivate.h"
#import "VSSVerifyIdentityRequest.h"
#import "VSSVerifyIdentityHTTPRequest.h"
#import "VSSConfirmIdentityRequest.h"
#import "VSSConfirmIdentityHTTPRequest.h"
#import "VSSValidateIdentityRequest.h"
#import "VSSValidateIdentityHTTPRequest.h"
#import "VSSGetChallengeMessageHTTPRequest.h"
#import "VSSAuthAckHTTPRequest.h"
#import "VSSObtainTokenHTTPRequest.h"
#import "VSSRefreshTokenHTTPRequest.h"
#import "VSSVerifyTokenHTTPRequest.h"

NSString *const kVSSClientErrorDomain = @"VSSClientErrorDomain";

static NSString *const kVSSAccessCodeGrantType = @"access_code";
static NSString *const kVSSRefreshTokenGrantType = @"refresh_token";

NSString * const kVSSAuthServicePublicKeyInBase64 = @"LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZzd0ZRWUhLb1pJemowQ0FRWUtLd1lCQkFHWFZRRUZBUU5DQUFRRGNONFR4endIV0VOR00zQmJxb1VuTWFVdQpLbTc4Sk9DWFhKN3I1ejdOalFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUEKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==";

@interface VSSClient ()

@property (nonatomic) NSOperationQueue * __nonnull queue;
@property (nonatomic) NSURLSession * __nonnull urlSession;

@end

@implementation VSSClient

#pragma mark - Lifecycle

- (instancetype)initWithServiceConfig:(VSSServiceConfig *)serviceConfig {
    self = [super init];
    if (self) {
        _serviceConfig = [serviceConfig copy];
    
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 10;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:_queue];
    }
    
    return self;
}

- (instancetype)initWithApplicationToken:(NSString *)token {
    return [self initWithServiceConfig:[VSSServiceConfig serviceConfigWithToken:token]];
}

- (instancetype)init {
    return [self initWithServiceConfig:[VSSServiceConfig defaultServiceConfig]];
}

- (void)dealloc {
    [_urlSession invalidateAndCancel];
    [_queue cancelAllOperations];
}

#pragma mark - Public class logic

- (void)send:(VSSHTTPRequest *)request requiresAccessToken:(BOOL)requiresAccessToken {
    if (request == nil) {
        return;
    }
    
    /// Before sending any request set proper token value into corresponding header field:
    if (requiresAccessToken) {
        if (self.serviceConfig.token.length > 0) {
            [request setRequestHeaders:@{ kVSSAccessTokenHeader: [NSString stringWithFormat:@"VIRGIL %@", self.serviceConfig.token]}];
        }
    }
    
#if USE_SERVICE_REQUEST_DEBUG
    {
        VSSRDLog(@"%@: request URL: %@", NSStringFromClass(request.class), request.request.URL);
        VSSRDLog(@"%@: request method: %@", NSStringFromClass(request.class), request.request.HTTPMethod);
        if (request.request.HTTPBody.length) {
            NSString *logStr = [[NSString alloc] initWithData:request.request.HTTPBody encoding:NSUTF8StringEncoding];
            VSSRDLog(@"%@: request body: %@", NSStringFromClass(request.class), logStr);
        }
        VSSRDLog(@"%@: request headers: %@", NSStringFromClass(request.class), request.request.allHTTPHeaderFields);
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL:request.request.URL];
        for (NSHTTPCookie *cookie in cookies) {
            VSSRDLog(@"*******COOKIE: %@: %@", [cookie name], [cookie value]);
        }
    }
#endif
    
    NSURLSessionDataTask *task = [request taskForSession:self.urlSession];
    [task resume];
}

#pragma mark - Implementation of VSSClient protocol

- (void)createCardWithRequest:(VSSCreateCardRequest *)request completion:(void (^)(VSSCard *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.registrationAuthorityURL];
    VSSCreateCardHTTPRequest *httpRequest = [[VSSCreateCardHTTPRequest alloc] initWithContext:context createCardRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSCreateCardHTTPRequest *r = [request vss_as:[VSSCreateCardHTTPRequest class]];
            VSSCardResponse *cardResponse = r.cardResponse;
            
            if (self.serviceConfig.cardValidator != nil) {
                if (![self.serviceConfig.cardValidator validateCardResponse:cardResponse]) {
                    callback(nil, [[NSError alloc] initWithDomain:kVSSClientErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Error validating card signatures" }]);
                    return;
                }
            }
            
            callback([cardResponse buildCard], nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:YES];
}

- (void)createCardRelationWithSignedCardRequest:(VSSSignedCardRequest *)request completion:(void (^)(NSError *))callback {
    if (request.signatures.count != 1) {
        callback([[NSError alloc] initWithDomain:kVSSClientErrorDomain code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"VSSSignedCardRequest should contain 1 signature" }]);
        return;
    }
    
    NSString *cardId = request.signatures.allKeys[0];
    
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceURL];
    VSSCreateCardRelationHTTPRequest *httpRequest = [[VSSCreateCardRelationHTTPRequest alloc] initWithContext:context cardId:cardId signedCardRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(request.error);
            }
            return;
        }
        
        if (callback != nil) {
            callback(nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:YES];
}

- (void)removeCardRelationWithRequest:(VSSRemoveCardRelationRequest *)request completion:(void (^)(NSError *))callback {
    if (request.signatures.count != 1) {
        callback([[NSError alloc] initWithDomain:kVSSClientErrorDomain code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"VSSSignedCardRequest should contain 1 signature" }]);
        return;
    }
    
    NSString *cardId = request.signatures.allKeys[0];
    
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceURL];
    VSSRemoveCardRelationHTTPRequest *httpRequest = [[VSSRemoveCardRelationHTTPRequest alloc] initWithContext:context cardId:cardId removeCardRelationRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(request.error);
            }
            return;
        }
        
        if (callback != nil) {
            callback(nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:YES];
}

- (void)getCardWithId:(NSString *)cardId completion:(void (^)(VSSCard *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceROURL];
    VSSGetCardHTTPRequest *httpRequest = [[VSSGetCardHTTPRequest alloc] initWithContext:context cardId:cardId];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSGetCardHTTPRequest *r = [request vss_as:[VSSGetCardHTTPRequest class]];
            if (self.serviceConfig.cardValidator != nil) {
                if (![self.serviceConfig.cardValidator validateCardResponse:r.cardResponse]) {
                    callback(nil, [[NSError alloc] initWithDomain:kVSSClientErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Error validating card signatures" }]);
                    return;
                }
            }
            callback([r.cardResponse buildCard], nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:YES];
}

- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria *)criteria completion:(void (^)(NSArray<VSSCard *> *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceROURL];
    VSSSearchCardsHTTPRequest *httpRequest = [[VSSSearchCardsHTTPRequest alloc] initWithContext:context searchCardsCriteria:criteria];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSSearchCardsHTTPRequest *r = [request vss_as:[VSSSearchCardsHTTPRequest class]];
            NSMutableArray<VSSCard *> *cardsArray = nil;
            if (r.cardResponses.count > 0) {
                cardsArray = [[NSMutableArray alloc] initWithCapacity:r.cardResponses.count];
                for (VSSCardResponse *response in r.cardResponses) {
                    if (self.serviceConfig.cardValidator != nil) {
                        if (![self.serviceConfig.cardValidator validateCardResponse:response]) {
                            callback(nil, [[NSError alloc] initWithDomain:kVSSClientErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Error validating card signatures" }]);
                            return;
                        }
                    }
                    
                    [cardsArray addObject:[response buildCard]];
                }
            }
            
            callback(cardsArray, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:YES];
}

- (void)revokeCardWithRequest:(VSSRevokeCardRequest *)request completion:(void (^)(NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.registrationAuthorityURL];
    VSSRevokeCardHTTPRequest *httpRequest = [[VSSRevokeCardHTTPRequest alloc] initWithContext:context revokeCardRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(request.error);
            }
            return;
        }
        
        if (callback != nil) {
            callback(nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:YES];
}

- (void)verifyIdentity:(NSString *)identity identityType:(NSString *)identityType extraFields:(NSDictionary<NSString *, NSString *> *)extraFields completion:(void (^)(NSString *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.identityServiceURL];
    VSSVerifyIdentityRequest *request = [[VSSVerifyIdentityRequest alloc] initWithIdentity:identity identityType:identityType extraFields:extraFields];
    VSSVerifyIdentityHTTPRequest *httpRequest = [[VSSVerifyIdentityHTTPRequest alloc] initWithContext:context verifyIdentityRequest:request];

    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSVerifyIdentityHTTPRequest *r = [request vss_as:[VSSVerifyIdentityHTTPRequest class]];
            callback(r.verifyIdentityResponse.actionId, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)confirmIdentityWithActionId:(NSString *)actionId confirmationCode:(NSString *)confirmationCode timeToLive:(NSInteger)timeToLive countToLive:(NSInteger)countToLive completion:(void (^)(VSSConfirmIdentityResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.identityServiceURL];
    VSSConfirmIdentityRequest *request = [[VSSConfirmIdentityRequest alloc] initWithConfirmationCode:confirmationCode actionId:actionId tokenTTL:timeToLive tokenCTL:countToLive];
    VSSConfirmIdentityHTTPRequest *httpRequest = [[VSSConfirmIdentityHTTPRequest alloc] initWithContext:context confirmIdentityRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSConfirmIdentityHTTPRequest *r = [request vss_as:[VSSConfirmIdentityHTTPRequest class]];
            callback(r.confirmIdentityResponse, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)validateIdentity:(NSString *)identity identityType:(NSString *)identityType validationToken:(NSString *)validationToken completion:(void (^)(NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.identityServiceURL];
    VSSValidateIdentityRequest *request = [[VSSValidateIdentityRequest alloc] initWithIdentityType:identityType identityValue:identity validationToken:validationToken];
    VSSValidateIdentityHTTPRequest *httpRequest = [[VSSValidateIdentityHTTPRequest alloc] initWithContext:context validateIdentityRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(request.error);
            }
            return;
        }
        
        if (callback != nil) {
            callback(nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)getChallengeMessageForVirgilCardWithId:(NSString *)virgilCardId completion:(void (^)(VSSChallengeMessageResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.authServiceURL];
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
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)ackChallengeMessageWithAuthGrantId:(NSString *)authGrantId encryptedMessage:(NSData *)encryptedMessage completion:(void (^)(NSString *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.authServiceURL];
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
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)obtainAccessTokenWithAccessCode:(NSString *)accessCode completion:(void (^)(VSSObtainTokenResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.authServiceURL];
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
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken completion:(void (^)(VSSTokenResponse *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.authServiceURL];
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
    
    [self send:httpRequest requiresAccessToken:NO];
}

- (void)verifyAccessToken:(NSString *)accessToken completion:(void (^)(NSString *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.authServiceURL];
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
    
    [self send:httpRequest requiresAccessToken:NO];
}

@end
