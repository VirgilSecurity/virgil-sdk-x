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

#import "VSSCreateCardRequest.h"
#import "VSSSearchCardsRequest.h"
#import "VSSGetCardRequest.h"
#import "VSSRevokeCardRequest.h"

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

- (void)send:(VSSRequest *)request {
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

- (void)registerCard:(VSSCard *)card completion:(void (^)(VSSCard *, NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceURL];
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithContext:context card:card];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSCreateCardRequest *r = [request as:[VSSCreateCardRequest class]];
            VSSCard *card = r.card;
            
            if (self.serviceConfig.cardValidator != nil) {
                if (![self.serviceConfig.cardValidator validateCard:card]) {
                    callback(nil, [[NSError alloc] initWithDomain:kVSSClientErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Error validating card signatures" }]);
                    return;
                }
            }
            
            callback(card, nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)getCardWithId:(NSString *)cardId completion:(void (^)(VSSCard *, NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceROURL];
    VSSGetCardRequest *request = [[VSSGetCardRequest alloc] initWithContext:context cardId:cardId];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSGetCardRequest *r = [request as:[VSSGetCardRequest class]];
            callback(r.card, nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria *)criteria completion:(void (^)(NSArray<VSSCard *> *, NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceROURL];
    VSSSearchCardsRequest *request = [[VSSSearchCardsRequest alloc] initWithContext:context searchCardsCriteria:criteria];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSSearchCardsRequest *r = [request as:[VSSSearchCardsRequest class]];
            callback(r.cards, nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)revokeCard:(VSSRevokeCard *)revokeCard completion:(void (^)(NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:self.serviceConfig.cardsServiceURL];
    VSSRevokeCardRequest *request = [[VSSRevokeCardRequest alloc] initWithContext:context revokeCard:revokeCard];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
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
    
    request.completionHandler = handler;
    
    [self send:request];
}

@end
