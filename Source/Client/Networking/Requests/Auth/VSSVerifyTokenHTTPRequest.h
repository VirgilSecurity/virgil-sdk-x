//
//  VSSVerifyTokenHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthBaseHTTPRequest.h"
#import "VSSVerifyTokenRequest.h"
#import "VSSVerifyTokenResponse.h"

@interface VSSVerifyTokenHTTPRequest : VSSAuthBaseHTTPRequest

@property (nonatomic) VSSVerifyTokenResponse * __nullable verifyTokenResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context verifyTokenRequest:(VSSVerifyTokenRequest * __nonnull)request;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
