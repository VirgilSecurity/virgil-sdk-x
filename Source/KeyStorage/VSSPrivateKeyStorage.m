//
//  VSSPrivateKeyStorage.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/16/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKeyStorage.h"
#import "VSSKeyEntry.h"

@implementation VSSPrivateKeyStorage

- (instancetype)init:(id<VSAPrivateKeyExporter>)privateKeyExporter {
    self = [super init];
    if (self) {
        _privateKeyExporter = privateKeyExporter;
        _keyStorage = [[VSSKeyStorage alloc] init];
    }
    
    return self;
}

- (BOOL)storeKeyEntry:(id<VSAPrivateKey> __nonnull)privateKey name:(NSString * __nonnull)name meta:(NSDictionary<NSString *, NSString *> * __nullable)meta error:(NSError * __nullable * __nullable)errorPtr {
    NSData *privateKeyInstance = [_privateKeyExporter exportPrivateKeyWithPrivateKey:privateKey error:errorPtr];
    
    if (*errorPtr) {
        return NO;
    }
    
    VSSKeyEntry *keyEntry = [VSSKeyEntry keyEntryWithName:name value:privateKeyInstance meta:meta];
    
    [_keyStorage storeKeyEntry:keyEntry error:errorPtr];
    
    if (*errorPtr) {
        return NO;
    }
    
    return YES;
}

- (id<VSAPrivateKey> __nonnull)loadWithName:(NSString * __nonnull)name getMeta:(NSDictionary<NSString *, NSString *> * __nullable * __nullable)meta error:(NSError * __nullable * __nullable)errorPtr {
    VSSKeyEntry *keyEntry = [_keyStorage loadKeyEntryWithName:name error:errorPtr];
    
    if (*errorPtr) {
        return nil;
    }
    
    id<VSAPrivateKey> privateKey = [_privateKeyExporter importPrivateKeyWithData:[keyEntry value] error:errorPtr];
    
    if (*errorPtr) {
        return nil;
    }
    
    *meta = [keyEntry meta];
    
    return privateKey;
}

- (BOOL)existsKeyEntryWithName:(NSString * __nonnull)name {
    return [_keyStorage existsKeyEntryWithName:name];
}

- (BOOL)deleteKeyEntryWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr {
    return [_keyStorage deleteKeyEntryWithName:name error:errorPtr];
}

@end
