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
#import "VSSKeyAttrsPrivate.h"

NSString *const kVSSKeyStorageErrorDomain = @"VSSKeyStorageErrorDomain";

static NSString *privateKeyIdentifierFormat = @".%@.privatekey.%@\0";

@interface VSSKeyStorage ()

- (NSMutableDictionary * __nonnull)baseKeychainQueryForName:(NSString * __nonnull)name;
- (NSMutableDictionary * __nonnull)baseExtendedKeychainQueryForName:(NSString * __nonnull)name;

@end

@implementation VSSKeyStorage

- (instancetype)init {
    VSSKeyStorageConfiguration *configuration = [VSSKeyStorageConfiguration keyStorageConfigurationWithDefaultValues];
    
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
    NSMutableDictionary *query = [self baseExtendedKeychainQueryForName:keyEntry.name];
    
    NSData *keyEntryData = [NSKeyedArchiver archivedDataWithRootObject:keyEntry];
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

- (BOOL)storeKeyEntries:(NSArray<VSSKeyEntry *> * __nonnull)keyEntries error:(NSError * __nullable * __nullable)errorPtr {
    // FIXME: Optimize
    for (VSSKeyEntry *keyEntry in keyEntries) {
        NSError *err;
        [self storeKeyEntry:keyEntry error:&err];
        
        if (err != nil){
            if (errorPtr != nil) {
                *errorPtr = err;
            }
            return NO;
        }
    }
    
//    NSMutableArray *queries = [[NSMutableArray alloc] initWithCapacity:keyEntries.count];
//    
//    for (VSSKeyEntry *keyEntry in keyEntries) {
//        NSMutableDictionary *query = [self baseExtendedKeychainQueryForName:keyEntry.name];
//        
//        NSData *keyEntryData = [NSKeyedArchiver archivedDataWithRootObject:keyEntry];
//        NSMutableDictionary *keySpecificData = [NSMutableDictionary dictionaryWithDictionary:
//            @{
//              (__bridge id)kSecValueData: keyEntryData,
//              }];
//        
//        [query addEntriesFromDictionary:keySpecificData];
//        
//        [queries addObject:query];
//    }
//    
//    NSDictionary *query;
//    if (keyEntries.count > 1) {
//        query = @{
//                  (__bridge id)kSecUseItemList: queries
//                  };
//    }
//    else {
//        query = queries[0];
//    }
//    
//    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, nil);
//    
//    if (status != errSecSuccess) {
//        if (errorPtr != nil) {
//            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while storing key in the keychain. See \"Security Error Codes\" (SecBase.h)." }];
//        }
//        
//        return NO;
//    }
    
    return YES;
}

- (BOOL)updateKeyEntry:(VSSKeyEntry *)keyEntry error:(NSError **)errorPtr {
    NSMutableDictionary *query = [self baseKeychainQueryForName:keyEntry.name];
    
    NSData *keyEntryData = [NSKeyedArchiver archivedDataWithRootObject:keyEntry];
    NSMutableDictionary *keySpecificData = [NSMutableDictionary dictionaryWithDictionary:
        @{
          (__bridge id)kSecValueData: keyEntryData,
          }];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)keySpecificData);
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while updating key in the keychain. See \"Security Error Codes\" (SecBase.h)." }];
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
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"No data found." }];
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
    NSMutableDictionary *query = [self baseKeychainQueryForName:name];
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, nil);
    
    if (status != errSecSuccess) {
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteKeyEntryWithName:(NSString *)name error:(NSError **)errorPtr {
    NSMutableDictionary *query = [self baseKeychainQueryForName:name];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while deleting key from the keychain. See \"Security Error Codes\" (SecBase.h)." }];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteKeyEntriesWithNames:(NSArray<NSString *> *)names error:(NSError **)errorPtr {
    // FIXME: Optimize
    for (NSString *name in names) {
        NSError *err;
        [self deleteKeyEntryWithName:name error:&err];
        
        if (err != nil){
            if (errorPtr != nil) {
                *errorPtr = err;
            }
            return NO;
        }
    }
    
//    NSMutableDictionary *query = [self baseKeychainQueryForNames:names];
//    
//    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
//    
//    if (status != errSecSuccess) {
//        if (errorPtr != nil) {
//            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while deleting keys from the keychain. See \"Security Error Codes\" (SecBase.h)." }];
//        }
//        return NO;
//    }
    
    return YES;
}

- (NSArray<VSSKeyEntry *> *)getAllKeysWithError:(NSError **)errorPtr {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:
      @{
        (__bridge id)kSecClass: (__bridge id)kSecClassKey,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
        (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll
        }];
    
    CFArrayRef outData = nil;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&outData);
    
    if (status == errSecItemNotFound) {
        return @[];
    }
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while searching keys in the keychain. See \"Security Error Codes\" (SecBase.h)." }];
        }
        return nil;
    }
    
    NSArray<NSData *> *entries = (__bridge NSArray*)outData;

    NSMutableArray<VSSKeyEntry *> *keysEntries = [[NSMutableArray alloc] initWithCapacity:entries.count];
    
    for (NSData *keyData in entries) {
        VSSKeyEntry *keyEntry = [NSKeyedUnarchiver unarchiveObjectWithData:keyData];
        
        [keysEntries addObject:keyEntry];
    }

    return keysEntries;
}

- (NSArray<VSSKeyAttrs *> *)getAllKeysAttrsWithError:(NSError **)errorPtr {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:
      @{
        (__bridge id)kSecClass: (__bridge id)kSecClassKey,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
        (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll
        }];
    
    CFArrayRef outData = nil;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&outData);
    
    if (status == errSecItemNotFound) {
        return @[];
    }
    
    if (status != errSecSuccess) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeyStorageErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Error while searching keys in the keychain. See \"Security Error Codes\" (SecBase.h)." }];
        }
        return nil;
    }
    
    NSArray<NSDictionary *> *entries = (__bridge NSArray*)outData;
    
    NSMutableArray<VSSKeyAttrs *> *keysAttrs = [[NSMutableArray alloc] initWithCapacity:entries.count];
    
    for (NSDictionary *entry in entries) {
        NSData *label = entry[(__bridge id)kSecAttrApplicationLabel];
        NSString *labelStr = [[NSString alloc] initWithData:label encoding:NSUTF8StringEncoding];
        NSDate *creationDate = entry[(__bridge id)kSecAttrCreationDate];
        
        VSSKeyAttrs *keyAttrs = [[VSSKeyAttrs alloc] initWithName:labelStr creationDate:creationDate];
        
        [keysAttrs addObject:keyAttrs];
    }
    
    return keysAttrs;
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
    
    // Access groups are not supported in simulator
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    if (self.configuration.accessGroup != nil) {
        additional[(__bridge id)kSecAttrAccessGroup] = self.configuration.accessGroup;
    }
#endif
    
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
