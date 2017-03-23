//
//  VSSGetChallengeMessageHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthBaseHTTPRequest.h"
#import "VSSChallengeMessageRequest.h"
#import "VSSChallengeMessageResponse.h"

@interface VSSGetChallengeMessageHTTPRequest : VSSAuthBaseHTTPRequest

@property (nonatomic) VSSChallengeMessageResponse * __nullable challengeMessageResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context challengeMessageRequest:(VSSChallengeMessageRequest * __nonnull)request;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
