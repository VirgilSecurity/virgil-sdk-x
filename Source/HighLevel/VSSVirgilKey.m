//
//  VSSVirgilKey.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilKey.h"
#import "VSSVirgilKeyPrivate.h"

@implementation VSSVirgilKey

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context privateKey:(VSSPrivateKey * __nonnull)privateKey {
    self = [super init];
    if (self) {
        _context = context;
        _privateKey = privateKey;
    }
    
    return self;
}

- (NSData *)exportWithPassword:(NSString *)password {
    return [self.context.crypto exportPrivateKey:self.privateKey withPassword:password];
}

- (NSData *)generateSignatureForData:(NSData *)data error:(NSError **)errorPtr {
    return [self.context.crypto generateSignatureForData:data withPrivateKey:self.privateKey error:errorPtr];
}

- (NSData *)decryptData:(NSData *)data error:(NSError **)errorPtr {
    return [self.context.crypto decryptData:data withPrivateKey:self.privateKey error:errorPtr];
}

- (NSData *)signThenEncryptData:(NSData *)data forRecipients:(NSArray<VSSVirgilCard *> *)recipients error:(NSError **)errorPtr {
    
    NSMutableArray<VSSPublicKey *> *recipientPublicKeys = [[NSMutableArray alloc] initWithCapacity:recipients.count];
    for (VSSVirgilCard *card in recipients) {
        [recipientPublicKeys addObject:card.publicKey];
    }
    
    return [self.context.crypto signThenEncryptData:data withPrivateKey:self.privateKey forRecipients:recipientPublicKeys error:errorPtr];
}

- (NSData *)decryptThenVerifyData:(NSData *)data from:(VSSVirgilCard *)card error:(NSError * __nullable * __nullable)errorPtr {
    return [self.context.crypto decryptThenVerifyData:data withPrivateKey:self.privateKey usingSignerPublicKey:card.publicKey error:errorPtr];
}

- (BOOL)storeWithName:(NSString *)name password:(NSString *)password error:(NSError **)errorPtr {
    NSData *exportedPrivateKey = [self.context.crypto exportPrivateKey:self.privateKey withPassword:password];
    VSSKeyEntry *keyEntry = [VSSKeyEntry keyEntryWithName:name value:exportedPrivateKey];
    
    return [self.context.keyStorage storeKeyEntry:keyEntry error:errorPtr];
}

- (NSData *)exportPublicKey {
    VSSPublicKey *publicKey = [self.context.crypto extractPublicKeyFromPrivateKey:self.privateKey];
    
    return [self.context.crypto exportPublicKey:publicKey];
}

@end
