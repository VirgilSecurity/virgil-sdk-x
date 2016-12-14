//
//  VSSConfirmIdentityHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSConfirmIdentityRequest.h"
#import "VSSConfirmIdentityResponse.h"

@interface VSSConfirmIdentityHTTPRequest : VSSIdentityBaseHTTPRequest

@property (nonatomic, readonly) VSSConfirmIdentityResponse * __nullable confirmIdentityResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context confirmIdentityRequest:(VSSConfirmIdentityRequest* __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
