//
//  VSSPersistentVirgilKey.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/11/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSPersistentVirgilKey.h"
#import "VSSVirgilKeyPrivate.h"
#import "VSSVirgilConfig.h"

@implementation VSSPersistentVirgilKey

+ (instancetype)virgilKeyWithName:(NSString *)name keyPair:(VSSKeyPair *)keyPair password:(NSString *)password error:(NSError **)errorPtr {
    VSSPersistentVirgilKey *key = [[self alloc] initWithName:name keyPair:keyPair];
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    id<VSSKeyStorage> storage = VSSVirgilConfig.sharedInstance.keyStorage;
    
    if ([storage existsKeyEntryWithName:name]) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSVirgilKeyErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Error storing VSSKeyEntry. Entry with this name already exists." }];
        }
        
        return nil;
    }
    
    NSData *exportedPrivateKey = [crypto exportPrivateKey:keyPair.privateKey withPassword:password];
    VSSKeyEntry *keyEntry = [VSSKeyEntry keyEntryWithName:name value:exportedPrivateKey];
    
    NSError *error;
    if (![storage storeKeyEntry:keyEntry error:&error]) {
        if (errorPtr != nil) {
            *errorPtr = error;
        }
        
        return nil;
    }
    
    return key;
}

+ (instancetype)virgilKeyWithName:(NSString *)name password:(NSString *)password error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    VSSKeyPair *keyPair = [crypto generateKeyPair];
    return [self virgilKeyWithName:name keyPair:keyPair password:password error:errorPtr];
}

+ (instancetype)loadPersistentVirgilKeyWithName:(NSString *)name password:(NSString *)password error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    id<VSSKeyStorage> storage = VSSVirgilConfig.sharedInstance.keyStorage;
    
    if ([storage existsKeyEntryWithName:name]) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSVirgilKeyErrorDomain code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"Entry with this name doesn't exist." }];
        }
        return nil;
    }
    
    NSError *error;
    VSSKeyEntry *keyEntry = [storage loadKeyEntryWithName:name error:&error];
    if (keyEntry == nil) {
        if (errorPtr != nil) {
            *errorPtr = error;
        }
        return nil;
    }
    
    VSSPrivateKey *privateKey = [crypto importPrivateKeyFromData:keyEntry.value];
    VSSPublicKey *publicKey = [crypto extractPublicKeyFromPrivateKey:privateKey];
    
    VSSKeyPair *keyPair = [[VSSKeyPair alloc] initWithPrivateKey:privateKey publicKey:publicKey];
    
    return [[self alloc] initWithName:name keyPair:keyPair];
}

- (BOOL)destroyWithError:(NSError **)errorPtr {
    id<VSSKeyStorage> storage = VSSVirgilConfig.sharedInstance.keyStorage;
    
    return [storage deleteKeyEntryWithName:self.keyName error:errorPtr];
}

@end
