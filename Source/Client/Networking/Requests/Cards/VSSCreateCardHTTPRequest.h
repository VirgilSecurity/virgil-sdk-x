//
//  VSSCreateCardHTTPRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSCreateCardRequest.h"
#import "VSSCardResponse.h"

@interface VSSCreateCardHTTPRequest : VSSCardsBaseHTTPRequest

@property (nonatomic) VSSCardResponse * __nullable cardResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context createCardRequest:(VSSCreateCardRequest * __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
