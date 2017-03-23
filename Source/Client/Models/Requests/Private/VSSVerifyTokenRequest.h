//
//  VSSVerifyTokenRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSVerifyTokenRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull accessToken;

- (instancetype __nonnull)initWithAccessToken:(NSString * __nonnull)accessToken;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
