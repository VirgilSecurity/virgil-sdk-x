//
//  VSSValidateIdentityRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSValidateIdentityRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull identityType;
@property (nonatomic, copy, readonly) NSString * __nonnull identityValue;
@property (nonatomic, copy, readonly) NSString * __nonnull validationToken;

- (instancetype __nonnull)initWithIdentityType:(NSString * __nonnull)identityType identityValue:(NSString * __nonnull)identityValue validationToken:(NSString * __nonnull)validationToken;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
