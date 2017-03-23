//
//  VSSAuthCodeResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSDeserializable.h"

/**
 Response from Virgil Auth Service with auth code.
 */
@interface VSSAuthAckResponse : VSSBaseModel <VSSDeserializable>

/**
 NSString with auth code
 */
@property (nonatomic, copy, readonly) NSString * __nonnull code;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
