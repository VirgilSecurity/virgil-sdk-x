//
//  VSSChallengeMessageResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"

/**
 Response from Virgil Auth Service with challenge message.
 */
@interface VSSChallengeMessageResponse : VSSBaseModel

/**
 NSString with authorization grant id
 */
@property (nonatomic, copy, readonly) NSString * __nonnull authGrantId;

/**
 NSData with encrypted message. Message is encrypted for virgil card holder
 */
@property (nonatomic, copy, readonly) NSData * __nonnull encryptedMessage;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
