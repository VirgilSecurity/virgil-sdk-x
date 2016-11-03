//
//  VSSKeyStorageConfiguration.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageConfiguration.h"

@interface VSSKeyStorageConfiguration ()

- (instancetype __nonnull)initWithApplicationName:(NSString * __nonnull)applicationName accessibility:(NSString * __nonnull)accessibility accessGroup:(NSString * __nullable)accessGroup NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithApplicationName:(NSString * __nonnull)applicationName;

@end

@implementation VSSKeyStorageConfiguration

- (instancetype)initWithApplicationName:(NSString * __nonnull)applicationName {
    return [self initWithApplicationName:applicationName accessibility:(__bridge NSString*)kSecAttrAccessibleWhenUnlocked accessGroup:nil];
}

- (instancetype)initWithApplicationName:(NSString *)applicationName accessibility:(NSString *)accessibility accessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        _accessibility = [accessibility copy];
        _accessGroup = [accessGroup copy];
        _applicationName = [applicationName copy];
    }
    
    return self;
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithApplicationName:(NSString *)applicationName {
    return [[VSSKeyStorageConfiguration alloc] initWithApplicationName:applicationName];
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithApplicationName:(NSString *)applicationName accessibility:(NSString *)accessibility accessGroup:(NSString *)accessGroup {
    return [[VSSKeyStorageConfiguration alloc] initWithApplicationName:applicationName accessibility:accessibility accessGroup:accessGroup];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[VSSKeyStorageConfiguration alloc] initWithApplicationName:self.applicationName accessibility:self.accessibility accessGroup:self.accessGroup];
}

@end
