//
//  VSSKeyStorage.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "VSSKeyStorage.h"

NSString *const kVSSKeyStorageErrorDomain = @"VSSKeyStorageErrorDomain";

static NSString *privateKeyIdentifierFormat = @"com.virgilsecurity.virgilsdk.privatekey.%@.%@\0";

@interface VSSKeyStorage ()

- (NSMutableDictionary * __nonnull)baseKeychainQueryForName:(NSString * __nonnull)name;
- (NSMutableDictionary * __nonnull)baseExtendedKeychainQueryForName:(NSString * __nonnull)name;

@end

@implementation VSSKeyStorage

- (instancetype)initWithApplicationName:(NSString *)applicationName {
    VSSKeyStorageConfiguration *configuration = [VSSKeyStorageConfiguration keyStorageConfigurationWithApplicationName:applicationName];
    
    return [self initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(VSSKeyStorageConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = [configuration copy];
    }
    
    return self;
}

- (BOOL)storeKeyEntry:(VSSKeyEntry *)keyEntry error:(NSError **)errorPtr {
    NSData *keyEntryData = [NSKeyedArchiver archivedDataWithRootObject:keyEntry];
    
    NSMutableDictionary *query = [self baseExtendedKeychainQueryForName:keyEntry.name];
    
    NSMutableDictionary *keySpecificData = [NSMutableDictionary dictionaryWithDictionary:
        @{
          (__bridge id)kSecValueData: keyEntryData,
        }];
    
    [query addEntriesFromDictionary:keySpecificData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, nil);
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while storing key in the keychain. See \"Security Error Codes\" (SecBase.h)." }];
        }
        
        return NO;
    }
    
    return YES;
}

- (VSSKeyEntry *)loadKeyEntryWithName:(NSString *)name error:(NSError **)errorPtr {
    NSMutableDictionary *query = [self baseKeychainQueryForName:name];
    
    NSMutableDictionary *additional = [[NSMutableDictionary alloc] initWithDictionary:
        @{
          (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue
        }];
    
    [query addEntriesFromDictionary:additional];
    
    CFDataRef outData = nil;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&outData);
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while obtaining key from the keychain. See \"Security Error Codes\" (SecBase.h)." }];
        }
        return nil;
    }
    
    if (outData == nil) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"No data found." }];
        }
        return nil;
    }
    
    NSData *keyData = (__bridge NSData*)outData;
    
    VSSKeyEntry *keyEntry = [NSKeyedUnarchiver unarchiveObjectWithData:keyData];
    
    if (keyEntry == nil) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"Error while building VSSKeyEntry." }];
        }
        return nil;
    }
    
    return keyEntry;
}

- (BOOL)existsKeyEntryWithName:(NSString *)name {
    return NO;
}

- (BOOL)deleteKeyEntryWithName:(NSString *)name error:(NSError **)errorPtr {
    NSMutableDictionary *query = [self baseKeychainQueryForName:name];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while obtaining key from the keychain. See \"Security Error Codes\" (SecBase.h)." }];
        }
        return NO;
    }
    
    return YES;
}

- (NSMutableDictionary *)baseExtendedKeychainQueryForName:(NSString *)name {
    NSMutableDictionary *query = [self baseKeychainQueryForName:name];
    
    NSMutableDictionary *additional = [NSMutableDictionary dictionaryWithDictionary:
        @{
            (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
            (__bridge id)kSecAttrLabel: name,
            (__bridge id)kSecAttrIsPermanent: (__bridge id)kCFBooleanTrue,
            (__bridge id)kSecAttrCanEncrypt: (__bridge id)kCFBooleanTrue,
            (__bridge id)kSecAttrCanDecrypt: (__bridge id)kCFBooleanFalse,
            (__bridge id)kSecAttrCanDerive: (__bridge id)kCFBooleanFalse,
            (__bridge id)kSecAttrCanSign: (__bridge id)kCFBooleanTrue,
            (__bridge id)kSecAttrCanVerify: (__bridge id)kCFBooleanFalse,
            (__bridge id)kSecAttrCanWrap: (__bridge id)kCFBooleanFalse,
            (__bridge id)kSecAttrCanUnwrap: (__bridge id)kCFBooleanFalse,
            (__bridge id)kSecAttrSynchronizable: (__bridge id)kCFBooleanFalse,
        }];
    
    if (self.configuration.accessGroup != nil) {
        additional[(__bridge id)kSecAttrAccessGroup] = self.configuration.accessGroup;
    }
    
    [query addEntriesFromDictionary:additional];
    
    return query;
}

- (NSMutableDictionary *)baseKeychainQueryForName:(NSString *)name {
    NSString *tag = [[NSString alloc] initWithFormat:privateKeyIdentifierFormat, self.configuration.applicationName, name];
    NSData *tagData = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:
        @{
            (__bridge id)kSecClass: (__bridge id)kSecClassKey,
            (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
            (__bridge id)kSecAttrApplicationLabel: [name dataUsingEncoding:NSUTF8StringEncoding],
            (__bridge id)kSecAttrApplicationTag: tagData
        }];
    
    return query;
}

@end
