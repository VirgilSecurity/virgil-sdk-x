//
//  VSSAuthServiceConfig.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSAuthServiceConfig.h"

@implementation VSSAuthServiceConfig

- (instancetype)initWithServiceURL:(NSURL *)serviceURL servicePublicKey:(NSData *)servicePublicKey {
    self = [super init];
    if (self) {
        _serviceURL = [serviceURL copy];
        _servicePublicKey = [servicePublicKey copy];
    }
    
    return self;
}

- (instancetype __nonnull)init {
    NSURL *authServiceURL = [[NSURL alloc] initWithString:@"https://auth.virgilsecurity.com/v4/"];
    
    NSData *authServicePublicKey = [[NSData alloc] initWithBase64EncodedString:@"LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZzd0ZRWUhLb1pJemowQ0FRWUtLd1lCQkFHWFZRRUZBUU5DQUFRRGNONFR4endIV0VOR00zQmJxb1VuTWFVdQpLbTc4Sk9DWFhKN3I1ejdOalFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUEKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==" options:0];
    
    return [self initWithServiceURL:authServiceURL servicePublicKey:authServicePublicKey];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[VSSAuthServiceConfig alloc] initWithServiceURL:self.serviceURL servicePublicKey:self.servicePublicKey];
}

@end
