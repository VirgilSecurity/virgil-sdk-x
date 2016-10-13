//
//  VSSRevokeCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCard.h"
#import "VSSSignedDataPrivate.h"
#import "VSSRevokeCardDataPrivate.h"

@implementation VSSRevokeCard

+ (instancetype)revokeCardWithId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    return [[VSSRevokeCard alloc] initWithCardId:cardId reason:reason];
}

- (instancetype)initWithCardId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardData *data = [[VSSRevokeCardData alloc] initWithCardId:cardId revocationReason:reason];
    return [self initWithRevokeCardData:data];
}

- (instancetype __nonnull)initWithRevokeCardData:(VSSRevokeCardData * __nonnull)data {
    self = [super initWithSnapshot:[data getCanonicalForm] signatures:nil cardVersion:nil createdAt:nil];
    if (self) {
        _data = data;
    }
    
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)candidate {
    self = [super initWithDict:candidate];
    if (self) {
        VSSRevokeCardData *revokeCardData = [VSSRevokeCardData createFromCanonicalForm:self.snapshot];
        if (revokeCardData == nil)
            return nil;
        _data = revokeCardData;
    }
    
    return self;
}

@end
