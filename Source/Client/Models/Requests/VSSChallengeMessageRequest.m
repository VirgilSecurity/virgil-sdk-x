//
//  VSSChallengeMessageRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSChallengeMessageRequest.h"
#import "VSSModelKeysPrivate.h"

@implementation VSSChallengeMessageRequest

- (instancetype)initWithOwnerVirgilCardId:(NSString *)cardId {
    self = [super init];
    if (self) {
        _ownerVirgilCardId = [cardId copy];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSAModelResourceOwnerCardId] = self.ownerVirgilCardId;
    
    return dict;
}

@end
