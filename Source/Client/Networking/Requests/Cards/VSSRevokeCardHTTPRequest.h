//
//  VSSRevokeCardHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardRequest.h"

@interface VSSRevokeCardHTTPRequest : VSSCardsBaseHTTPRequest

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context revokeCardRequest:(VSSRevokeCardRequest* __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
