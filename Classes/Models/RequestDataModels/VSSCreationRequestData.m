//
//  VSSCreationRequestData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCreationRequestData.h"

@interface VSSCreationRequestData ()

+ (NSString * __nonnull)getCannonicalForm;

@end

@implementation VSSCreationRequestData

- (instancetype)initWithIdentity:(NSString *)identity ofIdentityType:(NSString *)identityType publicKey:(VSSPublicKey *)publicKey {
    self = [super init];
    if (self) {
        _identity = [identity copy];
        _identityType = [identityType copy];
#warning replace with base64
        _publicKey = [publicKey copy];
    }
    return self;
}

+ (NSString *)getCannonicalForm {
    return @"";
}

@end
