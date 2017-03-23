//
//  VSSRefreshTokenHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthBaseHTTPRequest.h"
#import "VSSRefreshTokenRequest.h"
#import "VSSTokenResponse.h"

@interface VSSRefreshTokenHTTPRequest : VSSAuthBaseHTTPRequest

@property (nonatomic) VSSTokenResponse * __nullable tokenResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context refreshTokenRequest:(VSSRefreshTokenRequest * __nonnull)request;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
