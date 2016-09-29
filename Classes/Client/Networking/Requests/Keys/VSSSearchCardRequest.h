//
//  VSSSearchCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import "VSSRequestContext.h"
#import "VSSSearchCardsCriteria.h"
#import "VSSCardData.h"

@interface VSSSearchCardRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) NSArray <VSSCardData *>* __nullable cards;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context searchCriteria:(VSSSearchCardsCriteria * __nonnull)criteria;

@end
