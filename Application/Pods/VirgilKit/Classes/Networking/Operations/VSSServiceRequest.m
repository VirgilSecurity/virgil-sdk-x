//
//  VSSServiceRequest.m
//  VirgilKit
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSServiceRequest.h"
#import "VSSServiceRequest_Private.h"
#import "NSString+VSSXMLEscape.h"
#import "NSObject+VSSUtils.h"

const NSTimeInterval kVirgilServiceRequestDefaultTimeout = 45.0f;
NSString *const kVirgilServiceRequestDefaultMethod = @"POST";
NSString *const kVirgilServiceRequestErrorDomain = @"VirgilServiceRequestErrorDomain";
const NSInteger kVirgilServiceRequestCancelledErrorCode = -1000;
NSString *const kVirgilServiceRequestCancelledErrorDescription = @"Cancelled";

@interface VSSServiceRequest ()

@property (nonatomic, strong) NSString * __nonnull uuid;
@property (nonatomic, strong) NSString * __nonnull baseUrl;

@property (nonatomic, strong) NSObject *parsedResponse;

+ (NSString * __nonnull)HTTPMethodNameForMethod:(HTTPRequestMethod)method;
+ (HTTPRequestMethod)methodForHTTPMethodName:(NSString * __nullable)name;

@end

@implementation VSSServiceRequest

@synthesize uuid = _uuid;
@synthesize baseUrl = _baseUrl;
@synthesize request = _request;
@synthesize response = _response;
@synthesize error = _error;
@synthesize responseBody = _responseBody;
@synthesize completionHandler = _completionHandler;
@synthesize parsedResponse = _parsedResponse;

#pragma mark - Getters/Setters implementation

- (NSURLRequest *)request {
    if(_request != nil) {
        return _request;
    }
    
    NSURL *url = [NSURL URLWithString:[self.baseUrl stringByAppendingPathComponent:[self methodPath]]];
    
    NSMutableURLRequest* r = [NSMutableURLRequest requestWithURL:url];
    [r setTimeoutInterval:kVirgilServiceRequestDefaultTimeout];
    [r setHTTPMethod:kVirgilServiceRequestDefaultMethod];
    _request = r;
    return _request;
}

- (ServiceRequestCompletionHandler)completionHandler {
    ServiceRequestCompletionHandler blk = nil;
    @synchronized(self) {
        blk = [_completionHandler copy];
    }
    return blk;
}

- (void)setCompletionHandler:(ServiceRequestCompletionHandler)completionHandler {
    @synchronized(self) {
        _completionHandler = [completionHandler copy];
    }
}

#pragma mark - Initialization and configuration stuff

- (instancetype)init {
    return [self initWithBaseURL:@""];
}

- (instancetype)initWithBaseURL:(NSString *)url {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _baseUrl = url;
    _uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    return self;
}

#pragma mark - Methods to be overloaded by the descendent classes

- (NSString *)methodPath {
    return @"";
}

- (NSObject *)parseResponse {
    return nil;
}

- (NSError *)handleError:(NSObject *)candidate {
    return [candidate as:[NSError class]];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    return [candidate as:[NSError class]];
}

#pragma mark - Public class logic

- (void)setRequestMethod:(HTTPRequestMethod)method {
    NSMutableURLRequest *r = [self.request as:[NSMutableURLRequest class]];
    r.HTTPMethod = [[self class] HTTPMethodNameForMethod:method];
}

- (void)setRequestHeaders:(NSDictionary *)headers {
    for (NSString *header in [headers allKeys]) {
        NSString *value = [headers[header] as:[NSString class]];
        if (value != nil) {
            NSMutableURLRequest *r = [self.request as:[NSMutableURLRequest class]];
            [r setValue:value forHTTPHeaderField:header];
        }
    }
}

- (void)setRequestBody:(NSData *)body {
    if (body != nil) {
        NSMutableURLRequest *r = [self.request as:[NSMutableURLRequest class]];
        r.HTTPBody = body;
    }
}

- (void)setRequestQuery:(NSDictionary *)params {
    if (params == nil) {
        return;
    }
    
    NSMutableString *queryString = [[NSMutableString alloc] init];
    for (NSString *name in [params allKeys]) {
        NSString *value = [params[name] as:[NSString class]];
        if (value != nil) {
            [queryString appendFormat:@"&%@=%@", name, value];
        }
    }
    NSString *query = [queryString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"& "]];
    if (query.length == 0) {
        return;
    }
    
    NSMutableURLRequest *r = [self.request as:[NSMutableURLRequest class]];
    NSString *url = r.URL.absoluteString;
    r.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, query]];
}

#pragma mark - Private class logic

+ (NSString *)HTTPMethodNameForMethod:(HTTPRequestMethod)method {
    NSString *name = nil;
    switch (method) {
        case GET:
            name = @"GET";
            break;
        case POST:
            name = @"POST";
            break;
        case PUT:
            name = @"PUT";
            break;
        case DELETE:
            name = @"DELETE";
            break;
        default:
            name = kVirgilServiceRequestDefaultMethod;
            break;
    }
    return name;
}

+ (HTTPRequestMethod)methodForHTTPMethodName:(NSString *)name {
    HTTPRequestMethod method = POST;
    if ([name isEqualToString:@"GET"]) {
        method = GET;
    }
    else if ([name isEqualToString:@"PUT"]) {
        method = PUT;
    }
    else if ([name isEqualToString:@"DELETE"]) {
        method = DELETE;
    }
    
    return method;
}

@end
