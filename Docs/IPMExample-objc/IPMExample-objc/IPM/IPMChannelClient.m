//
//  IPMChannelClient.m
//  IPMExample-objc
//
//  Created by Pavel Gorb on 4/18/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

#import "IPMChannelClient.h"
#import "IPMConstants.h"
#import "IPMChannel.h"

@import VirgilSDK;

NS_ASSUME_NONNULL_BEGIN
@interface IPMChannelClient ()

@property (nonatomic, strong, readwrite) NSString *userId;
@property (nonatomic, strong, readwrite) id<IPMDataSource> _Nullable channel;

@property (nonatomic, strong) NSURLSession *session;

@end
NS_ASSUME_NONNULL_END

@implementation IPMChannelClient

@synthesize userId = _userId;
@synthesize channel = _channel;
@synthesize session = _session;

#pragma mark - Lifecycle

- (instancetype)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _userId = userId;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    return self;
}
- (instancetype)init {
    return [self initWithUserId:@""];
}

#pragma mark - Class logic

- (XAsyncActionResult)joinChannelWithName:(NSString *)name channelListener:(IPMDataSourceListener)listener {
    return ^ id {
        NSDictionary *dto = @{ kSenderIdentifier: self.userId };
        NSError *jsonError = nil;
        NSData *httpBody = [NSJSONSerialization dataWithJSONObject:dto options:0 error:&jsonError];
        if (jsonError != nil) {
            return jsonError;
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%@/channels/%@/join", kBaseURL, name];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:httpBody];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError * __block actionError = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                actionError = error;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            NSHTTPURLResponse *r = [response as:[NSHTTPURLResponse class]];
#ifdef DEBUG
            NSLog(@"%@: response URL: %@", NSStringFromClass(self.class), r.URL);
            NSLog(@"%@: response HTTP status code: %ld", NSStringFromClass(self.class), (long)r.statusCode);
            NSLog(@"%@: response headers: %@", NSStringFromClass(self.class), r.allHeaderFields);
            if( data.length != 0 )
            {
                NSString *bodyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@: response body: %@", NSStringFromClass(self.class), bodyStr);
            }
#endif
            if (r.statusCode >= 400) {
                NSError *httpError = [NSError errorWithDomain:@"HTTPError" code:r.statusCode userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString([NSHTTPURLResponse localizedStringForStatusCode:r.statusCode], @"No comments") }];
                actionError = httpError;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            NSError *jsonResponseError = nil;
            NSDictionary *candidate = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonResponseError];
            if (jsonResponseError != nil) {
                actionError = jsonResponseError;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            NSString *identityToken = [candidate[kIdentityToken] as:[NSString class]];
            if (identityToken.length == 0) {
                actionError = [NSError errorWithDomain:@"Error" code:-999 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"There is no identity token returned.", @"No comments") }];
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            IPMChannel *channel = [[IPMChannel alloc] initWithName:name token:identityToken];
            [channel startListeningWithHandler:listener];
            self.channel = channel;

            dispatch_semaphore_signal(semaphore);
        }];
        
#ifdef DEBUG
        NSLog(@"%@: request URL: %@", NSStringFromClass(self.class), request.URL);
        NSLog(@"%@: request method: %@", NSStringFromClass(self.class), request.HTTPMethod);
        if (request.HTTPBody.length) {
            NSString *logStr = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
            NSLog(@"%@: request body: %@", NSStringFromClass(self.class), logStr);
        }
        NSLog(@"%@: request headers: %@", NSStringFromClass(self.class), request.allHTTPHeaderFields);
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL:request.URL];
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"*******COOKIE: %@: %@", [cookie name], [cookie value]);
        }
#endif
        [task resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return actionError;
    };
}

- (void)leaveChannel {
    [self.channel stopListening];
    self.channel = nil;
}

@end
