//
//  VFJSONRequest.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFServiceRequest.h"

@interface VFJSONRequest : VFServiceRequest

- (void)setRequestBodyWithObject:(NSObject * __nonnull)candidate useUUID:(NSNumber * __nonnull)useUUID;

@end
