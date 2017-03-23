//
//  VSSAuthAckHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthBaseHTTPRequest.h"
#import "VSSAuthAckRequest.h"
#import "VSSAuthAckResponse.h"

@interface VSSAuthAckHTTPRequest : VSSAuthBaseHTTPRequest

@property (nonatomic) VSSAuthAckResponse * __nullable authAckResponse;
@property (nonatomic) NSString * __nonnull authGrantId;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context authGrantId:(NSString * __nonnull)authGrantId authAckRequest:(VSSAuthAckRequest * __nonnull)request;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
