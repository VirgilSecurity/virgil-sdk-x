//
//  VSSVirgilApi.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilApiProtocol.h"
#import "VSSVirgilApiContext.h"

/**
 NSString with Error Domain used for VSSVirgilApi-related errors
 */
extern NSString * __nonnull const kVSSVirgilApiErrorDomain;

/**
 Default implementation of VSSVirgilApi protocol.
 */
@interface VSSVirgilApi : NSObject <VSSVirgilApi>

/**
 Initializes instance with context.

 @param context VSSVirgilApiContext with all needed dependencies. See VSSVirgilApiContext.
 @return initialized VSSVirgilApiContext instance
 */
- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context NS_DESIGNATED_INITIALIZER;

/**
 Initializes instance with context.

 @param token access token to Virgil Service which can be obtained here https://developer.virgilsecurity.com/dashboard/
 @return initialized VSSVirgilApiContext instance
 */
- (instancetype __nonnull)initWithToken:(NSString * __nullable)token;

@end
