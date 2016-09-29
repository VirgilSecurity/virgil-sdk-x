//
//  VSSSigningRequestData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSignedData.h"
#import "VSSSignedDataPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSSignedData

- (instancetype)initWithSignatures:(NSDictionary * _Nullable)signatures cardVersion:(NSString * _Nullable)cardVersion createdAt:(NSDate * _Nullable)createdAt {
    self = [super init];
    if (self) {
        if (signatures != nil)
            _signatures = [signatures copy];
        else
            _signatures = [[NSMutableDictionary alloc] init];
    }
    return self;
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
    NSDictionary *signatures = [candidate[kVSSModelSigns] as:[NSDictionary class]];
    
    NSDate *createdAt = nil;
    NSString *createdAtStr = [candidate[kVSSModelCreatedAt] as:[NSString class]];
    if (createdAtStr != nil && [createdAtStr length] != 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        createdAt = [dateFormatter dateFromString:createdAtStr];
        return nil;
    }
    
    NSString *cardVersion = [candidate[kVSSModelCardVersion] as:[NSString class]];
    
    NSDictionary *signingDataDict = [candidate[kVSSModelSigns] as:[NSDictionary class]];
    if (signingDataDict == nil || [signingDataDict count] == 0)
        return nil;
    
    return [[VSSSignedData alloc] initWithSignatures:signatures cardVersion:cardVersion createdAt:createdAt];
}

@end
