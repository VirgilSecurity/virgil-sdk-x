//
//  VSSConfirmIdentityRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSConfirmIdentityRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull confirmationCode;
@property (nonatomic, copy, readonly) NSString * __nonnull actionId;
@property (nonatomic, readonly) NSInteger tokenTTL;
@property (nonatomic, readonly) NSInteger tokenCTL;

- (instancetype __nonnull)initWithConfirmationCode:(NSString * __nonnull)confirmationCode actionId:(NSString * __nonnull)actionId tokenTTL:(NSInteger)tokenTTL tokenCTL:(NSInteger)tokenCTL;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
