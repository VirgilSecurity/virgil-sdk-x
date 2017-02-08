//
//  VSSRevokeGlobalCardHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVraBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeGlobalCardRequest.h"

@interface VSSRevokeGlobalCardHTTPRequest : VSSVraBaseHTTPRequest

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context revokeCardRequest:(VSSRevokeGlobalCardRequest* __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
