//
//  VSSVerifyTokenResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSDeserializable.h"

@interface VSSVerifyTokenResponse : VSSBaseModel <VSSDeserializable>

@property (nonatomic, copy, readonly) NSString * __nonnull resourceOwnerVirgilCardId;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
