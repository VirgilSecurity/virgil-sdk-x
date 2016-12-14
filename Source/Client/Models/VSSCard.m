//
//  VSSCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardPrivate.h"

@implementation VSSCard

- (instancetype)initWithIdentifier:(NSString *)identifier identity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData scope:(VSSCardScope)scope data:(NSDictionary<NSString *,NSString *> *)data info:(NSDictionary<NSString *,NSString *> *)info createdAt:(NSDate *)createdAt cardVersion:(NSString *)cardVersion {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _identity = [identity copy];
        _identityType = [identityType copy];
        _publicKeyData = [publicKeyData copy];
        _scope = scope;
        if (data != nil)
            _data = [[NSDictionary alloc] initWithDictionary:data copyItems:YES];
        if (info != nil)
            _info = [[NSDictionary alloc] initWithDictionary:info copyItems:YES];
        _createdAt = [createdAt copy];
        _cardVersion = [cardVersion copy];
    }
    
    return self;
}

@end
