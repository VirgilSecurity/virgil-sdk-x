//
//  VFPrivateKey.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 10/12/15.
//  Copyright © 2015 VirgilSecurity. All rights reserved.
//

#import "VFPrivateKey.h"

@implementation VFPrivateKey

@synthesize key = _key;
@synthesize password = _password;

- (instancetype)initWithKey:(NSData *)key password:(NSString *)password {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _key = key;
    _password = password;
    return self;
}

- (instancetype)initWithKey:(NSData *)key {
    return [self initWithKey:key password:nil];
}

- (instancetype)init {
    return [self initWithKey:[NSData data] password:nil];
}

@end
