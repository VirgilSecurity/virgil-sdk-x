//
//  VSSCardMetaData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardMetaData.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCardMetaData

- (instancetype)initWithSigningData:(VSSSigningData *)signingData cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    self = [super init];
    if (self) {
        _signingData = signingData;
        if (cardVersion != nil)
            _cardVersion = [cardVersion copy];
        
        if (createdAt != nil)
            _createdAt = [createdAt copy];
    }
    return self;
}

- (NSDictionary *)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelSigns] = [self.signingData serialize];
    
    return dict;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSString *createdAtStr = [candidate[kVSSModelCreatedAt] as:[NSString class]];
    if (createdAtStr == nil || [createdAtStr length] == 0)
        return nil;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *createdAt = [dateFormatter dateFromString:createdAtStr];
    
    if (createdAt == nil)
        return nil;
    
    NSString *cardVersion = [candidate[kVSSModelCardVersion] as:[NSString class]];
    if (cardVersion == nil || [cardVersion length] == 0)
        return nil;
    
    NSDictionary *signingDataDict = [candidate[kVSSModelSigns] as:[NSDictionary class]];
    if (signingDataDict == nil || [signingDataDict count] == 0)
        return nil;
    
    VSSSigningData *signingData = [VSSSigningData deserializeFrom:signingDataDict];
    if (signingData == nil)
        return nil;
    
    return [[VSSCardMetaData alloc] initWithSigningData:signingData cardVersion:cardVersion createdAt:createdAt];
}

@end
