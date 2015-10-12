//
//  VFClient.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFClient.h"
#import "VFServiceRequest.h"

@interface VFClient ()

@property (nonatomic, strong, readwrite) NSString * __nonnull token;

@property (nonatomic, strong) NSOperationQueue * __nonnull queue;

@end

@implementation VFClient

@synthesize token = _token;
@synthesize queue = _queue;

#pragma mark - Lifecycle

- (instancetype)initWithApplicationToken:(NSString *)token {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _token = token;
    
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 10;
    return self;
}

- (instancetype)init {
    return [self initWithApplicationToken:@""];
}

- (void)dealloc {
    [_queue cancelAllOperations];
}

#pragma mark - Public class logic

- (NSString *)serviceURL {
    return @"";
}

- (void)send:(VFServiceRequest *)request {
    if (request == nil) {
        return;
    }
    [self.queue addOperation:request];
}

@end
