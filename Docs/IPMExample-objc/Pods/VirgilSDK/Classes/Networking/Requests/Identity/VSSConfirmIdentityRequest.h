//
//  VSSConfirmIdentityRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/16/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseRequest.h"
#import "VSSModelTypes.h"

@interface VSSConfirmIdentityRequest : VSSIdentityBaseRequest

@property (nonatomic, assign, readonly) VSSIdentityType type;
@property (nonatomic, strong, readonly) NSString * __nullable value;
@property (nonatomic, strong, readonly) NSString * __nullable validationToken;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context actionId:(GUID * __nonnull)actionId code:(NSString * __nonnull)code ttl:(NSNumber * __nullable)ttl ctl:(NSNumber * __nullable)ctl NS_DESIGNATED_INITIALIZER;

@end
