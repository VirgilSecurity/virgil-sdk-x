//
//  VSSCreateCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseRequest.h"
#import "VSSModelCommons.h"
#import "VSSCard.h"

@interface VSSCreateCardRequest : VSSCardsBaseRequest

@property (nonatomic) VSSCard * __nullable card;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context card:(VSSCard * __nonnull)card NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
