//
//  VSSIdentitiesManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSUserIdentity.h"
#import "VSSEmailIdentity.h"
#import "VSSApplicationIdentity.h"

/**
 Entry point for all interaction with Identities.
 */
@protocol VSSIdentitiesManager <NSObject>

/**
 Creates User Identity needed to create Virgil Cards in Application scope.

 @param value NSString with identity value
 @param type NSString with identity type (e.g. username)
 @return allocated and initialized VSSUserIdentity instance
 */
- (VSSUserIdentity * __nonnull)createUserIdentityWithValue:(NSString * __nonnull)value type:(NSString * __nonnull)type;

/**
 Creates Email Identity corresponding to specific email needed to create Virgil Cards in Global scope.
 NOTE1: email identities should be confirmed before use, see VSSEmailIdentity interface for details.
 NOTE2: confirmed email identities are for one time usage. User should create and confirm new identity for each create, revoke or any other operation.

 @param email NSString with email
 @return allocated and initialized VSSEmailIdentity instance
 */
- (VSSEmailIdentity * __nonnull)createEmailIdentityWithEmail:(NSString * __nonnull)email;

/**
 Creates Application Identity used for creating Application Virgil Cards.

 @param name NSString with application bundle name
 @return allocated and initialized VSSApplicationIdentity instance
 */
- (VSSApplicationIdentity * __nonnull)createApplicationIdentityWithName:(NSString * __nonnull)name;

@end
