//
//  VSSEmailIdentity.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilIdentity.h"

/**
 VSSVirgilIdentity subclass used for Virgil Cards corresponding to email in Global Scope.
 NOTE: These Identities are for one time usage and require confirmation.
 */
@interface VSSEmailIdentity : VSSVirgilIdentity

/**
 Requests email confirmation. Confirmation letter with code will be send to email.
 Use confirmWithConfirmationCode:completion: to confirm identity.

 @param options NSDictionary with custom options.
 @param callback callback with NSError instance if error occured
 */
- (void)checkWithOptions:(NSDictionary<NSString *, NSString *> * __nullable)options completion:(void (^ __nonnull)(NSError * __nullable))callback;

/**
 Confirms identity with confirmation code received on email.

 @param code NSString with confirmation code
 @param callback callback with NSError instance if error occured
 */
- (void)confirmWithConfirmationCode:(NSString * __nonnull)code completion:(void (^ __nonnull)(NSError * __nullable))callback;

@end
