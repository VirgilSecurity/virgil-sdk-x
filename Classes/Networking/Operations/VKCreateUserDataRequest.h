//
//  VKCreateUserDataRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import <VirgilFrameworkiOS/VFTypes.h>

@class VKUserData;

@interface VKCreateUserDataRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKUserData *userData;

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)publicKeyId userData:(VKUserData *)userData NS_DESIGNATED_INITIALIZER;

@end
