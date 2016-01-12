//
//  VSSClient.m
//  VirgilKit
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSClient.h"
#import "VSSServiceRequest.h"
#import "VSSServiceRequest_Private.h"
#import "NSObject+VSSUtils.h"

@interface VSSClient ()

@property (nonatomic, strong, readwrite) NSString * __nonnull token;
@property (nonatomic, strong) NSOperationQueue * __nonnull queue;
@property (nonatomic, strong) NSURLSession * __nonnull urlSession;

@end

@implementation VSSClient

@synthesize token = _token;
@synthesize queue = _queue;
@synthesize urlSession = _urlSession;

#pragma mark - Lifecycle

- (instancetype)initWithApplicationToken:(NSString *)token {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _token = token;
    
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 10;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    _urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:_queue];
    
    return self;
}

- (instancetype)init {
    return [self initWithApplicationToken:@""];
}

- (void)dealloc {
    [_urlSession invalidateAndCancel];
    [_queue cancelAllOperations];
}

#pragma mark - Public class logic

- (NSString *)serviceURL {
    return @"";
}

- (void)send:(VSSServiceRequest *)request {
    if (request == nil) {
        return;
    }
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (request.completionHandler != nil) {
            __weak VSSServiceRequest *weakRequest = request;
            if (error != nil) {
                request.error = error;
                request.completionHandler(weakRequest);
                return;
            }
            
            NSHTTPURLResponse *httpResponse = [response as:[NSHTTPURLResponse class]];
#if USE_SERVICE_REQUEST_DEBUG
            VFSRDLog(@"%@: response URL: %@", NSStringFromClass(request.class), httpResponse.URL);
            VFSRDLog(@"%@: response HTTP status code: %ld", NSStringFromClass(request.class), (long)httpResponse.statusCode);
            VFSRDLog(@"%@: response headers: %@", NSStringFromClass(request.class), httpResponse.allHeaderFields);
            if( data.length != 0 )
            {
                NSString *bodyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                VFSRDLog(@"%@: response body: %@", NSStringFromClass(request.class), bodyStr);
            }
#endif
            request.response = httpResponse;
            request.responseBody = data;
            
            switch (httpResponse.statusCode) {
                case 200:
                    break;
                default:
                request.error = [NSError errorWithDomain:kVirgilServiceRequestErrorDomain code:httpResponse.statusCode userInfo:nil];
                    break;
            }
            
            /// Fisrt of all we want to check if there is an error in response then we want to get
            /// an business logic error code from it to make the error much more detailed then just http status 400
            /// or whatever.
            NSObject *parsedResponse = [request parseResponse];
            // In any case we should check if response object contains some kind on business error.
            NSError *logicError = [request handleError:parsedResponse];
            if (logicError != nil) {
                /// Prioritize logic error over the HTTP Status code.
                request.error = logicError;
            }
            else {
                /// At this point we might still have generic error based on HTTP response status code and
                /// there is no handled error from service in the response body.
                /// In this case it is not necessary to handle the response (because handleResponse represents
                /// actually successful response without any kind of errors).
                if (request.error != nil) {
                    request.completionHandler(weakRequest);
                    return;
                }
                
                /// If there is no error so far, try to handle the response.
                /// This might also trigger an error.
                NSError *handlingError = [request handleResponse:parsedResponse];
                if (handlingError != nil) {
                    /// Prioritize handling error over anything that was before.
                    request.error = handlingError;
                }
            }
            
            request.completionHandler(weakRequest);
        }
    }];
    
    
#if USE_SERVICE_REQUEST_DEBUG
    {
        VFSRDLog(@"%@: request URL: %@", NSStringFromClass(request.class), request.request.URL);
        VFSRDLog(@"%@: request method: %@", NSStringFromClass(request.class), request.request.HTTPMethod);
        if (request.request.HTTPBody.length) {
            NSString *logStr = [[NSString alloc] initWithData:request.request.HTTPBody encoding:NSUTF8StringEncoding];
            VFSRDLog(@"%@: request body: %@", NSStringFromClass(request.class), logStr);
        }
        VFSRDLog(@"%@: request headers: %@", NSStringFromClass(request.class), request.request.allHTTPHeaderFields);
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL:request.request.URL];
        for (NSHTTPCookie *cookie in cookies) {
            VFSRDLog(@"*******COOKIE: %@: %@", [cookie name], [cookie value]);
        }
    }
#endif
    [task resume];
}

@end
