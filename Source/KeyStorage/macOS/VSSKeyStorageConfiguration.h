//
//  VSSKeyStorageConfiguration.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/4/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

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

@property (nonatomic, readonly) SecAccessRef __nullable accessRef;

/**
 Accessibility. See https://developer.apple.com/reference/security/keychain_services/keychain_item_accessibility_constants
 */
@property (nonatomic, readonly, copy) NSString * __nonnull accessibility;

/**
 ApplicationName.
 */
@property (nonatomic, readonly, copy) NSString * __nonnull applicationName;

@end
