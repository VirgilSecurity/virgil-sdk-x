//
//  VSSKeyStorageConfiguration.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageConfiguration.h"

@implementation VSSKeyStorageConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        _accessibility = (__bridge NSString*)kSecAttrAccessibleWhenUnlocked;
        _accessGroup = nil;
    }
    
    return self;
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithDefaultValues {
    return [[VSSKeyStorageConfiguration alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    // fixme
    return [[VSSKeyStorageConfiguration alloc] init];
}

@end
