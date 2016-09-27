//
//  @property (nonatomic, readonly) VSSCardScope scope; @property (nonatomic, copy, readonly) NSString * __nonnull identityType; @property (nonatomic, copy, readonly) NSArray<NSString *>* __nonnull identities;  VSSSigningRequestData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSigningData.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSSigningData

- (instancetype)initWithSignatures:(NSDictionary *)signatures {
    self = [super init];
    if (self) {
        if (signatures != nil)
            _signatures = [signatures copy];
        else
            _signatures = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)init {
    return [self initWithSignatures:nil];
}

- (void)addSignature:(NSString *)signature forFingerprint:(NSString *)fingerprint {
    ((NSMutableDictionary *)_signatures)[fingerprint] = signature;
}

- (NSDictionary *)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelSigns] = [self.signatures copy];
    
    return dict;
}

+ (instancetype __nullable)deserializeFrom:(NSDictionary * __nonnull)candidate {
    NSDictionary * signatures = [candidate[kVSSModelSigns] as:[NSDictionary class]];
    
    if (signatures == nil)
        return nil;
    
    return [[VSSSigningData alloc] initWithSignatures:signatures];
}

@end
