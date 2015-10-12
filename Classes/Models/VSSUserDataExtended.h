//
//  VSSUserDataExtended.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirgilFrameworkiOS/VSSUserData.h>

@class VSSIdBundle;

@interface VSSUserDataExtended : VSSUserData

/// Id bundle containing the containerId, publicKeyId and userDataId of this entity at the Virgil Keys Service
@property (nonatomic, copy, readonly) VSSIdBundle * __nonnull idb;
/// NSNumber containing a BOOL flag which indicates if this user data was confirmed (so user is owner of it) or not.
@property (nonatomic, copy, readonly) NSNumber * __nonnull confirmed;

- (instancetype __nonnull)initWithIdb:(VSSIdBundle * __nonnull)idb dataClass:(VSSUserDataClass)dataClass dataType:(VSSUserDataType)dataType value:(NSString * __nonnull)value confirmed:(NSNumber * __nonnull)confirmed NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithUserData:(VSSUserDataExtended * __nonnull)userData;

@end

