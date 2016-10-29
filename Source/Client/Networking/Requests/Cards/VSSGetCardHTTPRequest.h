//
//  VSSGetCardHTTPRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSCardResponse.h"

@interface VSSGetCardHTTPRequest : VSSCardsBaseHTTPRequest

@property (nonatomic, readonly) VSSCardResponse * __nullable cardResponse;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context cardId:(NSString * __nonnull)cardId NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
