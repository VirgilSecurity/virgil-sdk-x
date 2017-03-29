//
//  VSSKeysManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKey.h"

/**
 Entry point for all interaction with Virgil Keys.
 */
@protocol VSSKeysManager <NSObject>

/**
 Generates new key pair.

 @return allocated and initialized VSSVirgilKey instance
 */
- (VSSVirgilKey * __nonnull)generateKey;

/**
 Loads previously stored key from storage.
 User can store key using VSSVirgilKey storeWithName:password:error: method.

 @param name NSString with key name
 @param password NSString with key password if password was used while storing key
 @param errorPtr NSError pointer to return error if needed
 @return allocated and initialized VSSVirgilKey instance
 */
- (VSSVirgilKey * __nullable)loadKeyWithName:(NSString * __nonnull)name password:(NSString * __nullable)password error:(NSError * __nullable * __nullable)errorPtr;

/**
 Imports key from exported format.
 User can export key using VSSVirgilKey exportWithPassword: method.

 @param data NSData with exported key
 @param password NSString with key password if password was used while storing key
 @return allocated and initialized VSSVirgilKey instance
 */
- (VSSVirgilKey * __nullable)importKeyFromData:(NSData * __nonnull)data password:(NSString * __nullable)password;

/**
 Removes key from storage.

 @param name NSString with key name
 @param errorPtr NSError pointer to return error if needed
 @return YES if succeeded, NO otherwise
 */
- (BOOL)destroyKeyWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr;

@end
