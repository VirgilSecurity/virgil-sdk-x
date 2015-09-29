//
//  VFJSONRequest.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFServiceRequest.h"

@interface VFJSONRequest : VFServiceRequest

- (void)setRequestBodyWithObject:(NSObject *)candidate useUUID:(NSNumber *)useUUID;

@end
