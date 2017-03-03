//
//  VSSVirgilIdentity.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilIdentity.h"
#import "VSSVirgilIdentityPrivate.h"

@implementation VSSVirgilIdentity

- (instancetype)initWithContext:(VSSVirgilApiContext *)context value:(NSString *)value type:(NSString *)type {
    self = [super init];
    if (self) {
        _context = context;
        _value = [value copy];
        _type = [type copy];
    }
    
    return self;
}

- (BOOL)isConfimed {
    return YES;
}

@end
