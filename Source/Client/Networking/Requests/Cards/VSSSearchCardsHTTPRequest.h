//
//  VSSSearchCardsHTTPRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSHTTPRequestContext.h"
#import "VSSSearchCardsCriteria.h"
#import "VSSCard.h"

@interface VSSSearchCardsHTTPRequest : VSSCardsBaseHTTPRequest

@property (nonatomic, readonly) NSArray <VSSCard *>* __nullable cards;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context searchCardsCriteria:(VSSSearchCardsCriteria * __nonnull)criteria NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
