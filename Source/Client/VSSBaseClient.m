//
//  VSSBaseClient.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSBaseClient.h"
#import "VSSBaseClientPrivate.h"
#import "VSSHTTPRequest.h"

#ifdef DEBUG
#define USE_SERVICE_CLIENT_DEBUG 1
#endif

/// Debugging macro
#if USE_SERVICE_CLIENT_DEBUG
#  define VSSCLDLog(...) NSLog(__VA_ARGS__)
# else
#  define VSSCLDLog(...) /* nothing to log */
#endif

@implementation VSSBaseClient

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 10;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:_queue];
    }
    
    return self;
}

#pragma mark - Public class logic

- (void)send:(VSSHTTPRequest *)request {
    if (request == nil) {
        return;
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

- (void)dealloc {
    [_urlSession invalidateAndCancel];
    [_queue cancelAllOperations];
}

@end
