//
//  VSSIdentity.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 1/20/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSModelTypes.h"

@interface VSSIdentity : VSSBaseModel

@property (nonatomic, assign, readonly) VSSIdentityType type;
@property (nonatomic, copy, readonly) NSString * __nonnull value;
@property (nonatomic, copy, readonly) NSNumber * __nonnull isConfirmed;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate * __nullable)createdAt type:(VSSIdentityType)type value:(NSString * __nonnull)value isConfirmed:(NSNumber * __nonnull)isConfirmed NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate *__nullable)createdAt typeString:(NSString * __nonnull)typeString value:(NSString * __nonnull)value isConfirmed:(NSNumber * __nonnull)isConfirmed;

// Convenient methods for converting enums to strings and vice-versa.
+ (NSString * __nonnull)stringFromIdentityType:(VSSIdentityType)identityType;
+ (VSSIdentityType)identityTypeFromString:(NSString * __nullable)itCandidate;

@end
