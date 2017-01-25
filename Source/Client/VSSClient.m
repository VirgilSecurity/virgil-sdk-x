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
#import "VSSCreateGlobalCardHTTPRequest.h"
#import "VSSSearchCardsHTTPRequest.h"
#import "VSSGetCardHTTPRequest.h"
#import "VSSRevokeCardHTTPRequest.h"
#import "VSSRevokeGlobalCardHTTPRequest.h"
#import "VSSCardResponsePrivate.h"
#import "VSSVerifyIdentityRequest.h"
#import "VSSVerifyIdentityHTTPRequest.h"
#import "VSSConfirmIdentityRequest.h"
#import "VSSConfirmIdentityHTTPRequest.h"
#import "VSSValidateIdentityRequest.h"
#import "VSSValidateIdentityHTTPRequest.h"


NSString *const kVSSClientErrorDomain = @"VSSClientErrorDomain";

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

- (void)dealloc {
    [_urlSession invalidateAndCancel];
    [_queue cancelAllOperations];
}

#pragma mark - Public class logic

- (void)send:(VSSHTTPRequest *)request {
    if (request == nil) {
        return;
    }
    
    /// Before sending any request set proper token value into corresponding header field:
    if (self.serviceConfig.token.length > 0) {
        [request setRequestHeaders:@{ kVSSAccessTokenHeader: [NSString stringWithFormat:@"VIRGIL %@", self.serviceConfig.token]}];
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
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceURL];
    VSSCreateCardHTTPRequest *httpRequest = [[VSSCreateCardHTTPRequest alloc] initWithContext:context createCardRequest:request];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSCreateCardHTTPRequest *r = [request as:[VSSCreateCardHTTPRequest class]];
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
    
    [self send:httpRequest];
}

- (void)createGlobalCardWithRequest:(VSSCreateGlobalCardRequest *)request validationToken:(NSString *)validationToken completion:(void (^)(VSSCard *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.registrationAuthorityURL];
    VSSCreateGlobalCardHTTPRequest *httpRequest = [[VSSCreateGlobalCardHTTPRequest alloc] initWithContext:context createCardRequest:request validationToken:validationToken];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSCreateGlobalCardHTTPRequest *r = [request as:[VSSCreateGlobalCardHTTPRequest class]];
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
    
    [self send:httpRequest];
}

- (void)getCardWithId:(NSString *)cardId completion:(void (^)(VSSCard *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceROURL];
    VSSGetCardHTTPRequest *request = [[VSSGetCardHTTPRequest alloc] initWithContext:context cardId:cardId];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSGetCardHTTPRequest *r = [request as:[VSSGetCardHTTPRequest class]];
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
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria *)criteria completion:(void (^)(NSArray<VSSCard *> *, NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceROURL];
    VSSSearchCardsHTTPRequest *request = [[VSSSearchCardsHTTPRequest alloc] initWithContext:context searchCardsCriteria:criteria];
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSSearchCardsHTTPRequest *r = [request as:[VSSSearchCardsHTTPRequest class]];
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
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)revokeCardWithRequest:(VSSRevokeCardRequest *)request completion:(void (^)(NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceURL];
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
    
    [self send:httpRequest];
}

- (void)revokeGlobalCardWithRequest:(VSSRevokeGlobalCardRequest *)request validationToken:(NSString *)validationToken completion:(void (^)(NSError *))callback {
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceConfig.registrationAuthorityURL];
    VSSRevokeGlobalCardHTTPRequest *httpRequest = [[VSSRevokeGlobalCardHTTPRequest alloc] initWithContext:context revokeCardRequest:request validationToken:validationToken];
    
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
    
    [self send:httpRequest];
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
            VSSVerifyIdentityHTTPRequest *r = [request as:[VSSVerifyIdentityHTTPRequest class]];
            callback(r.verifyIdentityResponse.actionId, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
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
            VSSConfirmIdentityHTTPRequest *r = [request as:[VSSConfirmIdentityHTTPRequest class]];
            callback(r.confirmIdentityResponse, nil);
        }
        return;
    };
    
    httpRequest.completionHandler = handler;
    
    [self send:httpRequest];
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
    
    [self send:httpRequest];
}


@end
