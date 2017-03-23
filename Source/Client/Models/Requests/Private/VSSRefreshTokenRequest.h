//
//  VSSRefreshTokenRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSRefreshTokenRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull grantType;
@property (nonatomic, copy, readonly) NSString * __nonnull refreshToken;

- (instancetype __nonnull)initWithGrantType:(NSString * __nonnull)grantType refreshToken:(NSString * __nonnull)refreshToken;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
