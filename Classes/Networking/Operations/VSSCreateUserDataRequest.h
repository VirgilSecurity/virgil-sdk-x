//
//  VSSCreateUserDataRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import <VirgilKit/VSSTypes.h>

@class VSSUserData;
@class VSSUserDataExtended;

@interface VSSCreateUserDataRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSUserDataExtended * __nullable userData;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)publicKeyId userData:(VSSUserData * __nonnull)userData NS_DESIGNATED_INITIALIZER;

@end
