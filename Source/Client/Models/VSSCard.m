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

- (instancetype)initWithIdentifier:(NSString *)identifier identity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey scope:(VSSCardScope)scope data:(NSDictionary<NSString *,NSString *> *)data info:(NSDictionary<NSString *,NSString *> *)info createdAt:(NSDate *)createdAt cardVersion:(NSString *)cardVersion {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _identity = [identity copy];
        _identityType = [identityType copy];
        _publicKey = [publicKey copy];
        _scope = scope;
        _data = [data copy];
        _info = [info copy];
        _createdAt = [createdAt copy];
        _cardVersion = [cardVersion copy];
    }
    
    return self;
}

@end
