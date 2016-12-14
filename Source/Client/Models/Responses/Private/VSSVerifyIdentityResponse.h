//
//  VSSVerifyIdentityResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSDeserializable.h"

@interface VSSVerifyIdentityResponse : VSSBaseModel <VSSDeserializable>

@property (nonatomic, copy, readonly) NSString * __nonnull actionId;

- (instancetype __nonnull)initWithActionId:(NSString * __nonnull)actionId;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end

