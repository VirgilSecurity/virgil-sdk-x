//
//  Mailinator.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "Mailinator.h"
#import "MEmail.h"

#import "MailinatorInboxRequest.h"
#import "MailinatorEmailRequest.h"
#import "MailinatorConfig.h"
#import "VSSHTTPRequest.h"
#import "VSSHTTPRequest.h"

#import "NSObject+VSSUtils.h"

static NSString *const kMailinatorErrorDomain = @"MailinatorErrorDomain";

@interface Mailinator ()

@property (nonatomic) NSOperationQueue * __nonnull queue;
@property (nonatomic) NSURLSession * __nonnull urlSession;

@end

@implementation Mailinator

- (instancetype)initWithApplicationToken:(NSString *)token serviceUrl:(NSURL *)serviceUrl {
    self = [super init];
    
    if (self) {
        _token = [token copy];
        _serviceUrl = [serviceUrl copy];
        
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 10;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:_queue];
    }
    
    return self;
}

#pragma mark - Overrides

- (void)getInbox:(NSString *)name completionHandler:(void(^)(NSArray<MEmailMetadata *> *metadataList, NSError *error))completionHandler {
    if (name == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kMailinatorErrorDomain code:-100 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the inbox data can not be sent. Inbox name is not set.", @"GetInbox") }]);
            });
        }
        return;
    }
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            MailinatorInboxRequest *mrequest = [request vss_as:[MailinatorInboxRequest class]];
            if (mrequest.metadataList == nil) {
                completionHandler(nil, [NSError errorWithDomain:kMailinatorErrorDomain code:-103 userInfo:@{ NSLocalizedDescriptionKey: @"Error parsing response" }]);
                return;
            }
            completionHandler(mrequest.metadataList, nil);
        }
    };
    
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceUrl];
    MailinatorInboxRequest *request = [[MailinatorInboxRequest alloc] initWithContext:context token:self.token to:name];
    request.completionHandler = handler;
    [self send:request];
}

- (void)getEmail:(NSString *)emailId completionHandler:(void(^)(MEmail *email, NSError *error))completionHandler {
    if (emailId == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kMailinatorErrorDomain code:-102 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the email data can not be sent. Email id is not set.", @"GetEmail") }]);
            });
        }
        return;
    }
    
    VSSHTTPRequestCompletionHandler handler = ^(VSSHTTPRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            MailinatorEmailRequest *mrequest = [request vss_as:[MailinatorEmailRequest class]];
            if (mrequest.email == nil) {
                completionHandler(nil, [NSError errorWithDomain:kMailinatorErrorDomain code:-103 userInfo:@{ NSLocalizedDescriptionKey: @"Error parsing response" }]);
                return;
            }
            completionHandler(mrequest.email, nil);
        }
    };
    
    VSSHTTPRequestContext *context = [[VSSHTTPRequestContext alloc] initWithServiceUrl:self.serviceUrl];
    MailinatorEmailRequest *request = [[MailinatorEmailRequest alloc] initWithContext:context token:self.token emailId:emailId];
    request.completionHandler = handler;
    [self send:request];
}

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

@end
