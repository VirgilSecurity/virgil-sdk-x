//
//  VSSObtainTokenResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSTokenResponse.h"

/**
 Response from Virgil Auth Service with auth code.
 */
@interface VSSObtainTokenResponse : VSSTokenResponse

/**
 NSString with refresh token
 */
@property (nonatomic, copy, readonly) NSString * __nonnull refreshToken;

/**
 NSString with type of token
 */
@property (nonatomic, copy, readonly) NSString * __nonnull tokenType;


/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
