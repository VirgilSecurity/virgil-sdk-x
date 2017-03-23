//
//  VSSObtainAccessTokenHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthBaseHTTPRequest.h"
#import "VSSTokenRequest.h"
#import "VSSObtainTokenResponse.h"

@interface VSSObtainTokenHTTPRequest : VSSAuthBaseHTTPRequest

@property (nonatomic) VSSObtainTokenResponse * __nullable tokenResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context tokenRequest:(VSSTokenRequest * __nonnull)request;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
