//
//  VSSRevokeCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCard.h"

@interface VSSRevokeCardRequest : VSSCardsBaseRequest

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context revokeCard:(VSSRevokeCard * __nonnull)revokeCard NS_DESIGNATED_INITIALIZER;

@end
