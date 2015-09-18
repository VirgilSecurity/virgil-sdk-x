//
//  VKBaseModel.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFModel.h>
#import <VirgilFrameworkiOS/VFTypes.h>

@interface VKBaseModel : VFModel

@property (nonatomic, copy, readonly) VKIdBundle *Id;

- (instancetype)initWithId:(VKIdBundle *)Id NS_DESIGNATED_INITIALIZER;

@end
