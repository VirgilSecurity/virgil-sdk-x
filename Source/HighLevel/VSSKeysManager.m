//
//  VSSKeysManager.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSKeysManager.h"
#import "VSSKeysManagerPrivate.h"
#import "VSSVirgilKeyPrivate.h"

NSString * const kVSSKeysManagerErrorDomain = @"VSSKeysManagerErrorDomain";

@implementation VSSKeysManager

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    
    return self;
}

- (VSSVirgilKey *)generateKey {
    VSSKeyPair *keyPair = [self.context.crypto generateKeyPair];
    return [[VSSVirgilKey alloc] initWithContext:self.context privateKey:keyPair.privateKey];
}

- (VSSVirgilKey *)loadKeyWithName:(NSString *)name password:(NSString *)password error:(NSError **)errorPtr {
    if (![self.context.keyStorage existsKeyEntryWithName:name]) {
        if (errorPtr != nil)
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeysManagerErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Key with given name was not found." }];
        return nil;
    }
    
    VSSKeyEntry *keyEntry = [self.context.keyStorage loadKeyEntryWithName:name error:errorPtr];
    if (keyEntry == nil) {
        if (errorPtr != nil)
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeysManagerErrorDomain code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"Error while loading key with given name." }];
        return nil;
    }
    
    VSSPrivateKey *privateKey = [self.context.crypto importPrivateKeyFromData:keyEntry.value withPassword:password];
    if (privateKey == nil) {
        if (errorPtr != nil)
            *errorPtr = [[NSError alloc] initWithDomain:kVSSKeysManagerErrorDomain code:-1002 userInfo:@{ NSLocalizedDescriptionKey: @"Error while importing key with given name." }];
        return nil;
    }
    
    return [[VSSVirgilKey alloc] initWithContext:self.context privateKey:privateKey];
}

- (VSSVirgilKey *)importKeyFromData:(NSData *)data password:(NSString *)password {
    VSSPrivateKey *privateKey = [self.context.crypto importPrivateKeyFromData:data withPassword:password];
    
    if (privateKey == nil)
        return nil;
    
    return [[VSSVirgilKey alloc] initWithContext:self.context privateKey:privateKey];
}

- (BOOL)destroyKeyWithName:(NSString *)name error:(NSError **)errorPtr {
    return [self.context.keyStorage deleteKeyEntryWithName:name error:errorPtr];
}

@end
