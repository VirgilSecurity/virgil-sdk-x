//
//  VSSKeyStorageConfiguration.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/4/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSKeyStorageConfiguration.h"

@interface VSSKeyStorageConfiguration ()

- (instancetype __nonnull)initWithAccessibility:(NSString * __nullable)accessibility trustedApplications:(NSArray<NSString *> * __nullable)trustedApplications NS_DESIGNATED_INITIALIZER;

@end

@implementation VSSKeyStorageConfiguration

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithAccessibility:(NSString *)accessibility trustedApplications:(NSArray<NSString *> *)trustedApplications {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:accessibility trustedApplications:trustedApplications];
}

- (instancetype)initWithAccessibility:(NSString *)accessibility trustedApplications:(NSArray<NSString *> *)trustedApplications {
    self = [super init];
    if (self) {
        _accessibility = accessibility.length == 0 ? (__bridge NSString*)kSecAttrAccessibleWhenUnlocked : [accessibility copy];
        _trustedApplications = [trustedApplications copy];
        _applicationName = [NSBundle.mainBundle.bundleIdentifier copy];
    }
    
    return self;
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithDefaultValues {
    return [[VSSKeyStorageConfiguration alloc] init];
}

- (instancetype)init {
    return [self initWithAccessibility:nil trustedApplications:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:self.accessibility trustedApplications:self.trustedApplications];
}

@end
