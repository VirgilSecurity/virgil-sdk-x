//
//  VSSKeyStorageConfiguration.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class used to initialize default VSSKeyStorage implementation.
 See VSSKeyStorage.
 */
@interface VSSKeyStorageConfiguration: NSObject <NSCopying>

/**
 Default VSSKeyStorage values with applicationName = NSBundle.mainBundle.bundleIdentifier, accessibility = kSecAttrAccessibleWhenUnlocked, accessGroup = nil

 @return allocated and initialized VSSKeyStorageConfiguration instance
 */
+ (VSSKeyStorageConfiguration * __nonnull)keyStorageConfigurationWithDefaultValues;

/**
 Factory method which allocates and initalizes VSSKeyStorageConfiguration instance.

 @param accessibility see https://developer.apple.com/reference/security/keychain_services/keychain_item_accessibility_constants
 @param accessGroup see https://developer.apple.com/reference/security/ksecattraccessgroup
 @return allocated and initialized VSSKeyStorageConfiguration instance
 */
+ (VSSKeyStorageConfiguration * __nonnull)keyStorageConfigurationWithAccessibility:(NSString * __nullable)accessibility accessGroup:(NSString * __nullable)accessGroup;

/**
 Accessibility. See https://developer.apple.com/reference/security/keychain_services/keychain_item_accessibility_constants
 */
@property (nonatomic, readonly, copy) NSString * __nonnull accessibility;


/**
 AccessGroup. See https://developer.apple.com/reference/security/ksecattraccessgroup
 */
@property (nonatomic, readonly, copy) NSString * __nullable accessGroup;

/**
 ApplicationName.
 */
@property (nonatomic, readonly, copy) NSString * __nonnull applicationName;

@end
