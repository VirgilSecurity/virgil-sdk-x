//
//  @property (nonatomic, readonly) VSSCardScope scope; @property (nonatomic, copy, readonly) NSString * __nonnull identityType; @property (nonatomic, copy, readonly) NSArray<NSString *>* __nonnull identities;  VSSSigningRequestData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSigningRequestData.h"

@implementation VSSSigningRequestData

- (instancetype)init {
    self = [super init];
    if (self) {
        _signs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addSignature:(NSString *)signature forFingerprint:(NSString *)fingerprint {
    ((NSMutableDictionary *)_signs)[fingerprint] = signature;
}

@end
