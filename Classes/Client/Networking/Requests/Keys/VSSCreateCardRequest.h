//
//  VSSCreateCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import "VSSModelCommons.h"
#import "VSSCardData.h"
#import "VSSCardModel.h"

@interface VSSCreateCardRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSCardModel * __nullable cardModel;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context card:(VSSCardData * __nonnull)card NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
