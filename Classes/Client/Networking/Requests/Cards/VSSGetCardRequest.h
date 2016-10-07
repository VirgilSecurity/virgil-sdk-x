//
//  VSSGetCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseRequest.h"
#import "VSSModelCommons.h"
#import "VSSCard.h"

@interface VSSGetCardRequest : VSSCardsBaseRequest

@property (nonatomic, readonly) VSSCard * __nullable card;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context cardId:(NSString * __nonnull)cardId NS_DESIGNATED_INITIALIZER;

@end
