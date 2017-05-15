//
//  VSSHTTPRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSHTTPRequest.h"
#import "VSSHTTPRequestPrivate.h"
#import "VSSHTTPRequestContext.h"
#import "NSObject+VSSUtils.h"

const NSTimeInterval kVSSHTTPRequestDefaultTimeout = 45.0f;
NSString *const kVSSHTTPRequestDefaultMethod = @"POST";
NSString *const kVSSHTTPRequestErrorDomain = @"VSSHTTPRequestErrorDomain";

NSString *const kVSSAccessTokenHeader = @"Authorization";

@interface VSSHTTPRequest ()

+ (NSString * __nonnull)HTTPMethodNameForMethod:(HTTPRequestMethod)method;

@end

@implementation VSSHTTPRequest

@synthesize completionHandler = _completionHandler;

#pragma mark - Getters/Setters implementation

- (NSURLRequest *)request {
    if(_request != nil) {
        return _request;
    }
    
    NSURL *serviceURL = (self.context).serviceUrl;

    NSString *methodPath = [self methodPath];
    if ([methodPath hasPrefix:@"/"]) {
        methodPath = [methodPath substringFromIndex:1];
    }
    
    NSURL *url = [NSURL URLWithString:methodPath relativeToURL:serviceURL];
    
    NSMutableURLRequest* r = [NSMutableURLRequest requestWithURL:url];
    r.timeoutInterval = kVSSHTTPRequestDefaultTimeout;
    r.HTTPMethod = kVSSHTTPRequestDefaultMethod;
    _request = r;
    return _request;
}

- (VSSHTTPRequestCompletionHandler)completionHandler {
    VSSHTTPRequestCompletionHandler blk = nil;
    @synchronized(self) {
        blk = [_completionHandler copy];
    }
    return blk;
}

- (void)setCompletionHandler:(VSSHTTPRequestCompletionHandler)completionHandler {
    @synchronized(self) {
        _completionHandler = [completionHandler copy];
    }
}

#pragma mark - Initialization and configuration stuff

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context; {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _context = context;
    return self;
}

- (instancetype)init {
    return [self initWithContext:[[VSSHTTPRequestContext alloc] init]];
}

#pragma mark - Methods to be overloaded by the descendent classes

- (NSString *)methodPath {
    return @"";
}

- (NSObject *)parseResponse {
    return nil;
}

- (NSError *)handleError:(NSObject *)candidate code:(NSInteger)code {
    return [candidate vss_as:[NSError class]];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    return [candidate vss_as:[NSError class]];
}

#pragma mark - Public class logic

- (void)setRequestMethod:(HTTPRequestMethod)method {
    NSMutableURLRequest *r = [self.request vss_as:[NSMutableURLRequest class]];
    r.HTTPMethod = [[self class] HTTPMethodNameForMethod:method];
}

- (void)setRequestHeaders:(NSDictionary *)headers {
    for (NSString *header in headers.allKeys) {
        NSString *value = [headers[header] vss_as:[NSString class]];
        if (value != nil) {
            NSMutableURLRequest *r = [self.request vss_as:[NSMutableURLRequest class]];
            [r setValue:value forHTTPHeaderField:header];
        }
    }
}

- (void)setRequestBody:(NSData *)body {
    if (body != nil) {
        NSMutableURLRequest *r = [self.request vss_as:[NSMutableURLRequest class]];
        r.HTTPBody = body;
    }
}

- (NSURLSessionDataTask * __nonnull)taskForSession:(NSURLSession * __nonnull)session {
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (self.completionHandler != nil) {
            __weak VSSHTTPRequest *weakRequest = self;
            if (error != nil) {
                self.error = error;
                self.completionHandler(weakRequest);
                return;
            }
            
            NSHTTPURLResponse *httpResponse = [response vss_as:[NSHTTPURLResponse class]];
#if USE_SERVICE_REQUEST_DEBUG
            VSSRDLog(@"%@: response URL: %@", NSStringFromClass(self.class), httpResponse.URL);
            VSSRDLog(@"%@: response HTTP status code: %ld", NSStringFromClass(self.class), (long)httpResponse.statusCode);
            VSSRDLog(@"%@: response headers: %@", NSStringFromClass(self.class), httpResponse.allHeaderFields);
            if( data.length != 0 )
            {
                NSString *bodyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                VSSRDLog(@"%@: response body: %@", NSStringFromClass(self.class), bodyStr);
            }
#endif
            self.response = httpResponse;
            self.responseBody = data;
            
            switch (httpResponse.statusCode) {
                case 200:
                    break;
                default:
                    self.error = [[NSError alloc] initWithDomain:kVSSHTTPRequestErrorDomain code:httpResponse.statusCode userInfo:nil];
                    break;
            }
            
            /// Fisrt of all we want to check if there is an error in response then we want to get
            /// an business logic error code from it to make the error much more detailed then just http status 400
            /// or whatever.
            NSObject *parsedResponse = [self parseResponse];
            // In any case we should check if response object contains some kind of service error.
            NSError *logicError = [self handleError:parsedResponse code:httpResponse.statusCode];
            if (logicError != nil) {
                /// Prioritize logic error over the HTTP Status code.
                self.error = logicError;
            }
            else {
                /// At this point we might still have generic error based on HTTP response status code and
                /// there is no handled error from service in the response body.
                /// In this case it is not necessary to handle the response (because handleResponse represents
                /// actually successful response without any kind of errors).
                if (self.error != nil) {
                    self.completionHandler(weakRequest);
                    return;
                }
                
                /// If there is no error so far, try to handle the response.
                /// This might also trigger an error.
                NSError *handlingError = [self handleResponse:parsedResponse];
                if (handlingError != nil) {
                    /// Prioritize handling error over anything that was before.
                    self.error = handlingError;
                }
            }
            
            self.completionHandler(weakRequest);
        }
    }];
    
    return task;
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
            name = kVSSHTTPRequestDefaultMethod;
            break;
    }
    return name;
}

@end
