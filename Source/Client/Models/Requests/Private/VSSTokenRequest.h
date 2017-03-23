//
//  VSSTokenRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSTokenRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSString * __nonnull grantType;
@property (nonatomic, copy, readonly) NSString * __nonnull authCode;

- (instancetype __nonnull)initWithGrantType:(NSString * __nonnull)grantType authCode:(NSString * __nonnull)authCode;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
