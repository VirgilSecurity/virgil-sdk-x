//
//  VSSVerifyIdentityRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/16/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseRequest.h"
#import "VSSModelTypes.h"

@interface VSSVerifyIdentityRequest : VSSIdentityBaseRequest

@property (nonatomic, strong, readonly) GUID * __nullable actionId;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context type:(VSSIdentityType)type value:(NSString * __nonnull)value NS_DESIGNATED_INITIALIZER;

@end
