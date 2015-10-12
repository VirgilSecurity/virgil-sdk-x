//
//  VFServiceRequest.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFServiceRequest.h"
#import "NSString+VFXMLEscape.h"
#import "NSThread+VFBlockExecution.h"
#import "NSObject+VFUtils.h"

const NSTimeInterval kVirgilServiceRequestDefaultTimeout = 45.0f;
NSString *const kVirgilServiceRequestDefaultMethod = @"POST";
NSString *const kVirgilServiceRequestErrorHTTPResponseKey = @"ServiceRequestErrorHTTPResponseKey";
NSString *const kVirgilServiceRequestErrorHTTPBodyKey = @"ServiceRequestErrorHTTPBodyKey";
NSString *const kVirgilServiceRequestErrorDomain = @"VirgilServiceRequestErrorDomain";
const NSInteger kVirgilServiceRequestCancelledErrorCode = -1000;
NSString *const kVirgilServiceRequestCancelledErrorDescription = @"Cancelled";

@interface VFServiceRequest () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString * __nonnull uuid;
@property (nonatomic, strong) NSString * __nonnull baseUrl;
@property (nonatomic, strong) NSURLRequest * __nonnull request;
@property (nonatomic, strong) NSHTTPURLResponse * __nullable response;
@property (nonatomic, strong) NSError * __nullable error;

@property (nonatomic, strong) NSURLConnection * __nullable connection;
@property (nonatomic, strong) NSMutableData * __nullable actualResponseBody;
@property (nonatomic, strong) NSThread * __nullable thread;
@property (nonatomic, strong) NSRunLoop * __nullable runLoop;

@property (nonatomic, strong) NSObject *parsedResponse;

+ (NSString * __nonnull)HTTPMethodNameForMethod:(HTTPRequestMethod)method;
+ (HTTPRequestMethod)methodForHTTPMethodName:(NSString * __nullable)name;

@end

@implementation VFServiceRequest

@synthesize uuid = _uuid;
@synthesize baseUrl = _baseUrl;
@synthesize status = _status;
@synthesize request = _request;
@synthesize response = _response;
@synthesize error = _error;
@synthesize connection = _connection;
@dynamic responseBody;
@synthesize actualResponseBody = _actualResponseBody;
@synthesize responseBodyHandler = _responseBodyHandler;
@synthesize completionHandler = _completionHandler;
@synthesize thread = _thread;
@synthesize runLoop = _runLoop;
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

- (NSData *)responseBody {
    return self.actualResponseBody;
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
    
    __block VFServiceRequest* blockSelf = self;
    self.completionBlock = ^(void) {
        ServiceRequestCompletionHandler blk = blockSelf.completionHandler;
        if (blk) {
            blk(blockSelf);
            @synchronized(blockSelf) {
                blockSelf->_completionHandler = nil;
            }
        }
        blockSelf.completionBlock = nil;
        blockSelf = nil;
    };
}

- (void)setStatus:(ServiceRequestStatus)status {
    @synchronized(self) {
        if (status == _status) {
            return;
        }
        
        static const int transitionArray[4*4] = {
            // None ->
            /* None */ 0, /* InProgress */ 1, /* Done */ 3, /* Failed */ 3,
            
            // InProgress ->
            /* None */ 1, /* InProgress */ 0, /* Done */ 3, /* Failed */ 3,
            
            // Done ->
            /* None */ 0, /* InProgress */ 3, /* Done */ 0, /* Failed */ 0,
            
            // Failed ->
            /* None */ 0, /* InProgress */ 3, /* Done */ 0, /* Failed */ 0,
        };
        int trx = transitionArray[ (_status & 3) * 4 + (status & 3) ];
        
        if (trx & 1) {
            [self willChangeValueForKey:@"isExecuting"];
        }
        if (trx & 2) {
            [self willChangeValueForKey:@"isFinished"];
        }
        _status = status;
        if (trx & 1) {
            [self didChangeValueForKey:@"isExecuting"];
        }
        if (trx & 2) {
            [self didChangeValueForKey:@"isFinished"];
        }
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
    _status = None;
    _uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    return self;
}

- (void)dealloc {
    [_connection cancel];
}

#pragma mark - Overloaded NSOperation methods

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _status == InProgress;
}

- (BOOL)isFinished {
    ServiceRequestStatus status = self.status;
    return status == Done || status == Failed;
}

- (void)start {
    VFSRDLog(@"%@: start requested", NSStringFromClass(self.class));
    self.status = InProgress;
    [self startRequest];
}

- (void)cancel {
    BOOL actuallyCancel;

    VFSRDLog(@"%@: cancel requested", NSStringFromClass(self.class));
    
    @synchronized(self) {
        BOOL oldCancelled = [self isCancelled];
        [super cancel];
        actuallyCancel = !oldCancelled && self.status == InProgress;
    }
    if (actuallyCancel) {
        [self finishWithCancel];
    }
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

- (void)finishWithSuccess {
    [self.connection cancel];
    self.connection = nil;
    [self stopThread:^{
        self.status = Done;
    }];
    VFSRDLog(@"%@: finished with success", NSStringFromClass(self.class));
}

- (void)finishWithFailure:(NSError *)error {
    self.error = error;
    [self.connection cancel];
    self.connection = nil;
    VFSRDLog(@"%@: finished with error: %@", NSStringFromClass(self.class), [error localizedDescription]);
    [self stopThread:^{
        self.status = Failed;
    }];
}

- (void) finishWithCancel {
    [self finishWithFailure:[NSError errorWithDomain:kVirgilServiceRequestErrorDomain code:kVirgilServiceRequestCancelledErrorCode userInfo:@{ NSLocalizedDescriptionKey: kVirgilServiceRequestCancelledErrorDescription }]];
}

- (void)startRequest {
    if ([self isCancelled]) {
        [self finishWithCancel];
        VFSRDLog(@"%@: operation was cancelled before start", NSStringFromClass(self.class));
        return;
    }
    
    NSURLRequest *request = [self request];
    NSString *host = request.URL.host;
    if ([host hasSuffix:@"."]) {
        [self setRequestHeaders:@{ @"Host": [host substringToIndex:host.length-1] }];
    }
    
    if (![NSURLConnection canHandleRequest:request]) {
        [self finishWithCancel];
        VFSRDLog(@"%@: requested URL can not be handled", NSStringFromClass(self.class));
        return;
    }
    
#if USE_SERVICE_REQUEST_DEBUG
    {
        VFSRDLog(@"%@: request URL: %@", NSStringFromClass(self.class), request.URL);
        VFSRDLog(@"%@: request method: %@", NSStringFromClass(self.class), request.HTTPMethod);
        if (self.request.HTTPBody.length) {
            NSString *logStr = [[NSString alloc] initWithData:_request.HTTPBody encoding:NSUTF8StringEncoding];
            VFSRDLog(@"%@: request body: %@", NSStringFromClass(self.class), logStr);
        }
        VFSRDLog(@"%@: request headers: %@", NSStringFromClass(self.class), _request.allHTTPHeaderFields);
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL:self.request.URL];
        for (NSHTTPCookie *cookie in cookies) {
            VFSRDLog(@"*******COOKIE: %@: %@", [cookie name], [cookie value]);
        }
        
    }
#endif
    
    BOOL started = [self startThread:^(BOOL ok) {
        if (ok) {
            if (self.runLoop != nil) {
                self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
                NSString *runLoopMode = [self.runLoop currentMode];
                if (runLoopMode == nil) {
                    runLoopMode = (__bridge NSString*)kCFRunLoopDefaultMode;
                }
                [self.connection scheduleInRunLoop:self.runLoop forMode:runLoopMode];
                [self.connection start];
                VFSRDLog(@"%@: started", NSStringFromClass(self.class));
            }
        }
    }];
    
    if (!started) {
        VFSRDLog(@"Failed to start network operation thread.");
        [self finishWithCancel];
        return;
    }
}

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

#pragma mark - NSURLConnectionDelegate protocol implementation

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    #pragma unused(connection)
    #pragma unused(error)
    [self.connection cancel];
    self.connection = nil;
    VFSRDLog(@"%@: Connection did failed with error: %@", NSStringFromClass(self.class), [error localizedDescription]);

    [self finishWithFailure:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    #pragma unused(connection)
    if ([self isCancelled]){
        [self finishWithCancel];
    }
    return NO;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    #pragma unused(connection, response)
    if ([self isCancelled]) {
        [self finishWithCancel];
        return nil;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    #pragma unused(connection)
    if ([self isCancelled]) {
        [self finishWithCancel];
        return;
    }
    self.response = (NSHTTPURLResponse *)response;
    assert( [self.response isKindOfClass:[NSHTTPURLResponse class]] );
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    #pragma unused(connection)
    if ([self isCancelled]) {
        [self finishWithCancel];
        return;
    }
    if (self.responseBodyHandler) {
        self.responseBodyHandler(self, data);
    }
    else {
        if (self.actualResponseBody == nil) {
            self.actualResponseBody = [NSMutableData dataWithData:data];
        }
        else {
            [self.actualResponseBody appendData:data];
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    #pragma unused(connection, cachedResponse)
    if ([self isCancelled]) {
        [self finishWithCancel];
    }
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#if USE_SERVICE_REQUEST_DEBUG
    VFSRDLog(@"%@: response URL: %@", NSStringFromClass(self.class), _response.URL);
    VFSRDLog(@"%@: response HTTP status code: %ld", NSStringFromClass(self.class), (long)_response.statusCode);
    if( _actualResponseBody.length != 0 )
    {
        NSString *bodyStr = [[NSString alloc] initWithData:_actualResponseBody encoding:NSUTF8StringEncoding];
        VFSRDLog(@"%@: response body: %@", NSStringFromClass(self.class), bodyStr);
    }
    VFSRDLog(@"%@: response headers: %@", NSStringFromClass(self.class), _response.allHeaderFields);
#endif
    
    NSError* opError = nil;
    switch (self.response.statusCode) {
        case 200:
            break;
        default:
        {
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            if (self.response != nil) {
                userInfo[kVirgilServiceRequestErrorHTTPResponseKey] = self.response;
            }
            if (self.responseBody != nil) {
                userInfo[kVirgilServiceRequestErrorHTTPBodyKey] = self.responseBody;
            }
            opError = [NSError errorWithDomain:kVirgilServiceRequestErrorDomain code:self.response.statusCode userInfo:userInfo];
        }
            break;
    }

    self.parsedResponse = [self parseResponse];
    // In any case we should check if response object contains some kind on business error.
    NSError *logicError = [self handleError:self.parsedResponse];
    if (opError == nil && logicError == nil) {
        NSError *handlingError = [self handleResponse:self.parsedResponse];
        if (handlingError == nil) {
            [self finishWithSuccess];
        }
        else {
            // Use most recent error as most interesting.
            [self finishWithFailure:handlingError];
        }
    }
    else { // If opError or logicError is NOT nil
        // If logicError is not nil - use it (as it is parsed response from service).
        // Otherwise just use HTTP kind of error (HTTP Status code and generic message/domain).
        [self finishWithFailure:(logicError == nil) ? opError : logicError];
    }
}

#pragma mark - Thread management

- (void)nop {
    // Do nothing.
}

- (void) networkOperationThreadBody:(id)argument {
    @autoreleasepool {
        self.runLoop = [NSRunLoop currentRunLoop];
        [[NSThread currentThread] setName:NSStringFromClass(self.class)];
    }
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:NSTimeIntervalSince1970 target:self selector:@selector(nop) userInfo:nil repeats:NO];
    while (![[NSThread currentThread] isCancelled]) {
        @autoreleasepool {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, 0);
        }
    }
    [t invalidate];
    @autoreleasepool {
        self.runLoop = nil;
    }
    [NSThread exit];
}

- (BOOL) startThread:(void(^)(BOOL)) handler {
    if (self.thread != nil && self.thread.executing) {
        if (self.runLoop == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.runLoop = [NSRunLoop currentRunLoop];
                if ( handler != nil) {
                    handler(YES);
                }
            });
            return YES;
        }
    }
    
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(networkOperationThreadBody:) object:nil];
    if (self.thread == nil) {
        return NO;
    }
    
    [self.thread start];
    if (handler == nil) {
        while (self.thread != nil && self.runLoop == nil) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.05, 0);
        }
        return (self.thread != nil);
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.thread != nil && self.runLoop == nil) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.05, 0);
        }
        handler(self.thread != nil);
    });
    
    return self.thread != nil;
}

- (void) stopThread:(void(^)(void)) handler {
    if (self.thread != nil) {
        [self.thread cancel];
        self.thread = nil;
    }
    
    if (self.runLoop == nil) {
        if (handler != nil) {
            handler();
        }
        return;
    }
    
    if (handler == nil) {
        while (self.runLoop != nil) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, 0);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.runLoop != nil) {
            [NSThread sleepForTimeInterval:0.1];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            handler();
        });
    });
}

@end
