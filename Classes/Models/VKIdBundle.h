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

/// UUID of the container entity at the Virgil Keys Service
@property (nonatomic, copy, readonly) GUID *containerId;
/// UUID of the public key entity at the Virgil Keys Service
@property (nonatomic, copy, readonly) GUID *publicKeyId;
/// UUID of the user data entity at the Virgil Keys Service (might be nil if this IdBundle related to the public key entity).
@property (nonatomic, copy, readonly) GUID *userDataId;

- (instancetype)initWithContainerId:(GUID *)containerId publicKeyId:(GUID *)publicKeyId userDataId:(GUID *)userDataId NS_DESIGNATED_INITIALIZER;

@end
