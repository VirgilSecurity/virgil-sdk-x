//
//  VSSCreateCardHTTPRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSCard.h"

@interface VSSCreateCardHTTPRequest : VSSCardsBaseHTTPRequest

@property (nonatomic) VSSCard * __nullable card;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context card:(VSSCard * __nonnull)card NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
