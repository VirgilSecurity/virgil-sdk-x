//
//  VSSJSONRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSRequestExtended.h"

@interface VSSJSONRequest : VSSRequestExtended

- (void)setRequestBodyWithObject:(NSObject * __nonnull)candidate;

@end
