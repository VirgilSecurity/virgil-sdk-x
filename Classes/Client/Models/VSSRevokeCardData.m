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
#import "NSObject+VSSUtils.h"

@implementation VSSRevokeCardData

- (instancetype)initWithCardId:(NSString *)cardId revocationReason:(VSSCardRevocationReason)reason {
    self = [super init];
    if (self) {
        _cardId = [cardId copy];
        _revocationReason = reason;
    }
    
    return self;
}

+ (instancetype)createFromCanonicalForm:(NSData *)canonicalForm {
    if (canonicalForm.length == 0)
        return nil;
    
    NSError *parseError;
    NSObject *candidate = [NSJSONSerialization JSONObjectWithData:canonicalForm options:NSJSONReadingAllowFragments error:&parseError];
    
    if (parseError != nil)
        return nil;
    
    if ([candidate isKindOfClass:[NSDictionary class]]) {
        return [[VSSRevokeCardData alloc]initWithDict:(NSDictionary *)candidate];
    }
    
    return nil;
}

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *cardId = [candidate[kVSSModelCardId] as:[NSString class]];
    if (cardId.length == 0)
        return nil;
    
    NSString *revocationReasonStr = [candidate[kVSSModelRevocationReason] as:[NSString class]];
    if (revocationReasonStr.length == 0)
        return nil;
    
    VSSCardRevocationReason reason = vss_getCardRevocationReasonFromString(revocationReasonStr);
    
    return [self initWithCardId:cardId revocationReason:reason];
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
