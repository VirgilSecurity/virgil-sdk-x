//
//  VKCreateUserDataRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import <VirgilFrameworkiOS/VFTypes.h>

@class VFUserData;
@class VKUserData;

@interface VKCreateUserDataRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKUserData * __nullable userData;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)publicKeyId userData:(VFUserData * __nonnull)userData NS_DESIGNATED_INITIALIZER;

@end
