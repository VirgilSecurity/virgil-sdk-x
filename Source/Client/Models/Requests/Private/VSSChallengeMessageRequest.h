//
//  VSSChallengeMessageRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSChallengeMessageRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull ownerVirgilCardId;

- (instancetype __nonnull)initWithOwnerVirgilCardId:(NSString * __nonnull)cardId;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
