//
//  VSSCreateCardRelationHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSSignedCardRequest.h"

@interface VSSCreateCardRelationHTTPRequest : VSSCardsBaseHTTPRequest

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context cardId:(NSString * __nonnull)cardId signedCardRequest:(VSSSignedCardRequest * __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
