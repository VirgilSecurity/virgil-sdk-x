//
//  VSSPrivateKeyStorage.h
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/16/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#ifndef VSSPrivateKeyStorage_h
#define VSSPrivateKeyStorage_h

#import "VSSKeyStoragePublic.h"
#import <Foundation/Foundation.h>

@import VirgilCryptoAPI;

/**
 Class responsible for storing Private Keys
 */
@interface VSSPrivateKeyStorage : NSObject

/**
 PrivateKeyExporter implementation instance for import/export PrivateKey
 */
@property (nonatomic, copy, readonly) _Nonnull id<VSAPrivateKeyExporter> privateKeyExporter;

/**
 Instance for storing, loading, deleting KeyEntries
 */
@property (nonatomic, copy, readonly) VSSKeyStorage * __nonnull keyStorage;

/**
 VSSPrivateKeyStorage initializer.
 
 @param privateKeyExporter VSAPrivateKeyExporter to use it for import/export stored Private Keys
 @return allocated and initialized VSSPrivateKeyStorage instance
 */
- (instancetype __nonnull)init:(id<VSAPrivateKeyExporter> __nonnull)privateKeyExporter;

/**
 Stores Private Key with meta.
 @param privateKey VSAPrivateKey to store
 @param meta NSDictionary with any meta data
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)storeKeyEntry:(id<VSAPrivateKey> __nonnull)privateKey name:(NSString * __nonnull)name meta:(NSDictionary<NSString *, NSString *> * __nullable)meta error:(NSError * __nullable * __nullable)errorPtr;

/**
 Loads key Private Key and meta.
 @param name NSString with stored name
 @param meta pointer to NSDictionary for getting stored meta data
 @param errorPtr NSError pointer to return error if needed
 @return VSAPrivateKey if loading succeeded, nil otherwise
 */
- (id<VSAPrivateKey> __nonnull)loadWithName:(NSString * __nonnull)name getMeta:(NSDictionary<NSString *, NSString *> * __nullable *  __nullable)meta error:(NSError * __nullable * __nullable)errorPtr;

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
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end

#endif /* VSSPrivateKeyStorage_h */
