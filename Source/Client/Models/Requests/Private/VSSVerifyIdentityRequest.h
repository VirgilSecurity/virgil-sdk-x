
//
//  VSSVerifyEmailRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSVerifyIdentityRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull identity;
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nullable extraFields;

- (instancetype __nonnull)initWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType extraFields:(NSDictionary<NSString *, NSString *> * __nullable)extraFields;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
