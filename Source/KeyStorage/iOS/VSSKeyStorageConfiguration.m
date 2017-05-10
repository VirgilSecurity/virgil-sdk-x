//
//  VSSKeyStorageConfiguration.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageConfiguration.h"

@interface VSSKeyStorageConfiguration ()

- (instancetype __nonnull)initWithAccessibility:(NSString * __nullable)accessibility accessGroup:(NSString * __nullable)accessGroup NS_DESIGNATED_INITIALIZER;

@end

@implementation VSSKeyStorageConfiguration

- (instancetype)init {
    return [self initWithAccessibility:nil accessGroup:nil];
}

- (instancetype)initWithAccessibility:(NSString *)accessibility accessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        _accessibility = accessibility.length == 0 ? (__bridge NSString*)kSecAttrAccessibleWhenUnlocked : [accessibility copy];
        _accessGroup = [accessGroup copy];
        _applicationName = [NSBundle.mainBundle.bundleIdentifier copy];
    }
    
    return self;
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithDefaultValues {
    return [[VSSKeyStorageConfiguration alloc] init];
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithAccessibility:(NSString *)accessibility accessGroup:(NSString *)accessGroup {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:accessibility accessGroup:accessGroup];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:self.accessibility accessGroup:self.accessGroup];
}

@end
