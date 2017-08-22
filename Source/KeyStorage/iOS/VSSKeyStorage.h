//
//  VSSKeyStorage.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageProtocol.h"
#import "VSSKeyStorageConfiguration.h"

extern NSString * __nonnull const kVSSKeyStorageErrorDomain;

/**
 Default VSSKeyStorage protocol implementation using Keychain.
 */
@interface VSSKeyStorage : NSObject <VSSKeyStorage>

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
- (NSArray<NSData *> * __nullable)getAllKeysTagsWithError:(NSError * __nullable * __nullable)errorPtr;

@end
