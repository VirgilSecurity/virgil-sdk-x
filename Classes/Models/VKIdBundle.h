//
//  VKIdBundle.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFModel.h>
#import <VirgilFrameworkiOS/VFTypes.h>

@interface VKIdBundle : VFModel

@property (nonatomic, copy, readonly) GUID *containerId;
@property (nonatomic, copy, readonly) GUID *publicKeyId;
@property (nonatomic, copy, readonly) GUID *userDataId;

- (instancetype)initWithContainerId:(GUID *)containerId publicKeyId:(GUID *)publicKeyId userDataId:(GUID *)userDataId NS_DESIGNATED_INITIALIZER;

@end
