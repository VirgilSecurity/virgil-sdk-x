//
//  VSSKeyStorageProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/1/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSKeyEntry.h"

/**
 Protocol used for storing private keys.
 See VSSKeyEntry.
 */
@protocol VSSKeyStorage <NSObject>

/**
 Stores key entry.

 @param keyEntry VSSKeyEntry to store
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)storeKeyEntry:(VSSKeyEntry * __nonnull)keyEntry error:(NSError * __nullable * __nullable)errorPtr;

/**
 Updates key entry.

 @param keyEntry New VSSKeyEntry instance
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)updateKeyEntry:(VSSKeyEntry * __nonnull)keyEntry error:(NSError * __nullable * __nullable)errorPtr;

/**
 Loads key entry.

 @param name NSString with VSSKeyEntry name
 @param errorPtr NSError pointer to return error if needed
 @return VSSKeyEntry if loading succeeded, nil otherwise
 */
- (VSSKeyEntry * __nullable)loadKeyEntryWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr;

/**
 Checks whether key entry with given name exists.

 @param name NSString with VSSKeyEntry name
 @return YES if entry with this name exists, NO otherwise
 */
- (BOOL)existsKeyEntryWithName:(NSString * __nonnull)name;

/**
 Removes VSSKeyEntry with given name

 @param name NSString with VSSKeyEntry name
 @param errorPtr NSError pointer to return error if needed
 @return YES if succeeded, NO otherwise
 */
- (BOOL)deleteKeyEntryWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr;

@end
