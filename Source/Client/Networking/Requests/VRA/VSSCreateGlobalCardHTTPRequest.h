//
//  VSSCreateGlobalCardHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVraBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSCreateGlobalCardRequest.h"
#import "VSSCardResponse.h"

@interface VSSCreateGlobalCardHTTPRequest : VSSVraBaseHTTPRequest

@property (nonatomic) VSSCardResponse * __nullable cardResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context createGlobalCardRequest:(VSSCreateGlobalCardRequest * __nonnull)request validationToken:(NSString * __nonnull)validationToken NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
