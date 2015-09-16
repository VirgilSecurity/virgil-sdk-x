//
//  VKUserData.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirgilFrameworkiOS/VFUserData.h>

@class VKIdBundle;

@interface VKUserData : VFUserData

@property (nonatomic, copy, readonly) VKIdBundle *Id;
@property (nonatomic, copy, readonly) NSNumber *Confirmed;

- (instancetype)initWithId:(VKIdBundle *)Id Class:(VFUserDataClass)Class Type:(VFUserDataType)Type Value:(NSString *)Value Confirmed:(NSNumber *)Confirmed NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUserData:(VKUserData *)userData;

@end

