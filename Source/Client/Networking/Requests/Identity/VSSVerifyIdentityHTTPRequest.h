//
//  VSSVerifyIdentityHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSVerifyIdentityRequest.h"
#import "VSSVerifyIdentityResponse.h"

@interface VSSVerifyIdentityHTTPRequest : VSSIdentityBaseHTTPRequest

@property (nonatomic, readonly) VSSVerifyIdentityResponse * __nullable verifyIdentityResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context verifyIdentityRequest:(VSSVerifyIdentityRequest* __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
