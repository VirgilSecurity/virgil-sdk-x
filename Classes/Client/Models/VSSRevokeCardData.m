//
//  VSSRevokeCardData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardData.h"
#import "VSSRevokeCardDataPrivate.h"
#import "VSSModelCommons.h"
#import "VSSSignedDataPrivate.h"
#import "VSSModelKeys.h"
#import "VSSModelCommonsPrivate.h"

@implementation VSSRevokeCardData

- (instancetype)initWithCardId:(NSString *)cardId revocationReason:(VSSCardRevocationReason)reason {
    self = [super init];
    if (self) {
        _cardId = [cardId copy];
        _revocationReason = reason;
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelCardId] = [self.cardId copy];
    dict[kVSSModelRevocationReason] = vss_getRevocationReasonString(self.revocationReason);
    
    return dict;
}

- (NSData *)getCanonicalForm {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    
    return JSONData;
}

@end
