//
//  VSSKeyStorage.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageConfiguration.h"
#import "VSSKeyEntry.h"

extern NSString * __nonnull const kVSSKeyStorageErrorDomain;

/**
 Class responsible for storing, loading, deleting KeyEntries using Keychain.
 */
@interface VSSKeyStorage : NSObject

/**
 Stores key entry.
 @param keyEntry VSSKeyEntry to store
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)storeKeyEntry:(VSSKeyEntry * __nonnull)keyEntry error:(NSError * __nullable * __nullable)errorPtr;

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

@end
