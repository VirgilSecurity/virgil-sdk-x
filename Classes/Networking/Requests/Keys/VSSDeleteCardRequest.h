//
//  VSSDeleteCardRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import "VSSModelTypes.h"

@interface VSSDeleteCardRequest : VSSKeysBaseRequest

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context cardId:(GUID * __nonnull)cardId identity:(NSDictionary * __nonnull)identity NS_DESIGNATED_INITIALIZER;

@end
