//
//  VSSValidateIdentityHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSValidateIdentityRequest.h"

@interface VSSValidateIdentityHTTPRequest : VSSIdentityBaseHTTPRequest

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context validateIdentityRequest:(VSSValidateIdentityRequest* __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
