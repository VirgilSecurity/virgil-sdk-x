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
 Updates key entry.
 
 @param keyEntry New VSSKeyEntry instance
 @param errorPtr NSError pointer to return error if needed
 @return YES if storing succeeded, NO otherwise
 */
- (BOOL)updateKeyEntry:(VSSKeyEntry * __nonnull)keyEntry error:(NSError * __nullable * __nullable)errorPtr;

@end
