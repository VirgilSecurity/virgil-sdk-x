//
//  VSSRemoveCardRelationHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/21/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSRemoveCardRelationRequest.h"

@interface VSSRemoveCardRelationHTTPRequest : VSSCardsBaseHTTPRequest

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context cardId:(NSString * __nonnull)cardId removeCardRelationRequest:(VSSRemoveCardRelationRequest* __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
