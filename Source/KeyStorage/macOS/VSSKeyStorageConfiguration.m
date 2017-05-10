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

- (instancetype __nonnull)initWithAccessibility:(NSString * __nonnull)accessibility accessRef:(SecAccessRef __nullable)accessRef NS_DESIGNATED_INITIALIZER;

@end

@implementation VSSKeyStorageConfiguration

- (instancetype)initWithAccessibility:(NSString *)accessibility accessRef:(SecAccessRef)accessRef {
    self = [super init];
    if (self) {
        _accessibility = [accessibility copy];
        _accessRef = accessRef;
        _applicationName = [NSBundle.mainBundle.bundleIdentifier copy];
    }
    
    return self;
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithDefaultValues {
    return [[VSSKeyStorageConfiguration alloc] init];
}

- (instancetype)init {
    return [self initWithAccessibility:(__bridge NSString*)kSecAttrAccessibleWhenUnlocked accessRef:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[VSSKeyStorageConfiguration alloc] init];
}

-(void)dealloc {
    if (self.accessRef) {
        CFRelease(self.accessRef);
    }
}

@end
