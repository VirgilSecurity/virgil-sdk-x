//
//  VSSSearchCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"

@class VSSCard;
@class VSSPublicKey;
@class VSSSearchCardsCriteria;

@interface VSSSearchCardRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) NSArray <VSSCard *>* __nullable cards;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context searchCriteria:(VSSSearchCardsCriteria * __nonnull)criteria;

@end
