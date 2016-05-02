//
//  VSSIdentity.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 1/20/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSModelCommons.h"

@class VSSIdentityInfo;

@interface VSSIdentity : VSSBaseModel

@property (nonatomic, copy, readonly) NSString * __nonnull type;
@property (nonatomic, copy, readonly) NSString * __nonnull value;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate *__nullable)createdAt type:(NSString * __nonnull)type value:(NSString * __nonnull)value NS_DESIGNATED_INITIALIZER;

- (VSSIdentityInfo * __nonnull)asIdentityInfo;

@end
