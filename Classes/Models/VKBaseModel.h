//
//  VKBaseModel.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFModel.h>

@class VKIdBundle;

@interface VKBaseModel : VFModel

@property (nonatomic, copy, readonly) VKIdBundle * __nonnull idb;

- (instancetype __nonnull)initWithIdb:(VKIdBundle * __nonnull)idb NS_DESIGNATED_INITIALIZER;

@end
