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
    // FIXME
    if (![self.context.keyStorage existsKeyEntryWithName:name])
        return nil;
    
    VSSKeyEntry *keyEntry = [self.context.keyStorage loadKeyEntryWithName:name error:errorPtr];
    if (keyEntry == nil)
        return nil;
    
    VSSPrivateKey *privateKey = [self.context.crypto importPrivateKeyFromData:keyEntry.value withPassword:password];
    if (privateKey == nil)
        return nil;
    
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
