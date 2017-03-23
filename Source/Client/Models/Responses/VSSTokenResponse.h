//
//  VSSTokenResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"

/**
 Response from Virgil Auth Service with auth code.
 */
@interface VSSTokenResponse : VSSBaseModel

/**
 NSString with access token
 */
@property (nonatomic, copy, readonly) NSString * __nonnull accessToken;

/**
 NSString with expiration for access token in seconds
 */
@property (nonatomic, readonly) NSInteger expiresIn;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
