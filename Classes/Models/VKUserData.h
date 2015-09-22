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

/// Id bundle containing the containerId, publicKeyId and userDataId of this entity at the Virgil Keys Service
@property (nonatomic, copy, readonly) VKIdBundle *idb;
/// NSNumber containing a BOOL flag which indicates if this user data was confirmed (so user is owner of it) or not.
@property (nonatomic, copy, readonly) NSNumber *confirmed;

- (instancetype)initWithIdb:(VKIdBundle *)idb dataClass:(VFUserDataClass)dataClass dataType:(VFUserDataType)dataType value:(NSString *)value confirmed:(NSNumber *)confirmed NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUserData:(VKUserData *)userData;

@end

