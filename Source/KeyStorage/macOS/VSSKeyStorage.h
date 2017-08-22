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
 Initialized

 @param configuration Configuration
 @return initialized VSSKeyStorage instance
 */
- (instancetype __nonnull)initWithConfiguration:(VSSKeyStorageConfiguration * __nonnull)configuration NS_DESIGNATED_INITIALIZER;

@end
