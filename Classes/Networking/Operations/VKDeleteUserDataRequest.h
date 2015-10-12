//
//  VKDeleteUserDataRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import <VirgilFrameworkiOS/VFTypes.h>

@interface VKDeleteUserDataRequest : VKBaseRequest

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url userDataId:(GUID * __nonnull)userDataId NS_DESIGNATED_INITIALIZER;

@end
