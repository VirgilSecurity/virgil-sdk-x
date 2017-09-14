//
//  VSSKeyStorage.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageConfiguration.h"
#import "VSSKeyEntry.h"
#import "VSSKeyAttrs.h"

extern NSString * __nonnull const kVSSKeyStorageErrorDomain;

/**
 Default VSSKeyStorage protocol implementation using Keychain.
 */
@interface VSSKeyStorage : NSObject

/**
 Configuration.
 See VSSKeyStorageConfiguration
 */
@property (nonatomic, copy, readonly) VSSKeyStorageConfiguration * __nonnull configuration;

/**
 Initializer.

 @param configuration Configuration
 @return initialized VSSKeyStorage instance
 */
- (instancetype __nonnull)initWithConfiguration:(VSSKeyStorageConfiguration * __nonnull)configuration NS_DESIGNATED_INITIALIZER;

/**
 Updates key entry.
 
 @param keyEntry New VSSKeyEntry instance
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)updateKeyEntry:(VSSKeyEntry * __nonnull)keyEntry error:(NSError * __nullable * __nullable)errorPtr;

/**
 Returns all keys in the storage.

 @param errorPtr NSError pointer to return error if needed
 @return NSArray with all keys
 */
- (NSArray<VSSKeyEntry *> * __nullable)getAllKeysWithError:(NSError * __nullable * __nullable)errorPtr;

/**
 Returns all keys tags in the storage.

 @param errorPtr NSError pointer to return error if needed
 @return NSArray with all tags
 */
- (NSArray<VSSKeyAttrs *> * __nullable)getAllKeysAttrsWithError:(NSError * __nullable * __nullable)errorPtr;

/**
 Stores multiple key entries.
 
 @param keyEntries NSArray with VSSKeyEntry instances to store
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)storeKeyEntries:(NSArray<VSSKeyEntry *> * __nonnull)keyEntries error:(NSError * __nullable * __nullable)errorPtr;

/**
 Removes multiple key entries with given names.

 @param names NSArray with names
 @param errorPtr NSError pointer to return error if needed
 @return YES if succeeded, NO otherwise
 */
- (BOOL)deleteKeyEntriesWithNames:(NSArray<NSString *> * __nonnull)names error:(NSError * __nullable * __nullable)errorPtr;

/**
 Removes ALL keys.
 
 @param errorPtr NSError pointer to return error if needed
 @return YES if succeeded, NO otherwise
 */
- (BOOL)resetWithError:(NSError * __nullable * __nullable)errorPtr;

@end
