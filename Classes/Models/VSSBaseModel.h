//
//  VSSBaseModel.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VSSModel.h>

@class VSSIdBundle;

@interface VSSBaseModel : VSSModel

@property (nonatomic, copy, readonly) VSSIdBundle * __nonnull idb;

- (instancetype __nonnull)initWithIdb:(VSSIdBundle * __nonnull)idb NS_DESIGNATED_INITIALIZER;

@end
