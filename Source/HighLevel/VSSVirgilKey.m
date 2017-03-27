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
#import "VSSVirgilCardPrivate.h"

@implementation VSSVirgilKey

- (instancetype)initWithContext:(VSSVirgilApiContext *)context privateKey:(VSSPrivateKey *)privateKey {
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

- (NSData *)generateSignatureForBase64String:(NSString *)base64String error:(NSError **)errorPtr {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
    return [self.context.crypto generateSignatureForData:data withPrivateKey:self.privateKey error:errorPtr];
}

- (NSData *)decryptData:(NSData *)data error:(NSError **)errorPtr {
    return [self.context.crypto decryptData:data withPrivateKey:self.privateKey error:errorPtr];
}

- (NSData *)decryptBase64String:(NSString *)base64String error:(NSError **)errorPtr {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];

    return [self.context.crypto decryptData:data withPrivateKey:self.privateKey error:errorPtr];
}

- (NSData *)signThenEncryptData:(NSData *)data forRecipients:(NSArray<VSSVirgilCard *> *)recipients error:(NSError **)errorPtr {
    NSMutableArray<VSSPublicKey *> *recipientPublicKeys = [[NSMutableArray alloc] initWithCapacity:recipients.count];
    for (VSSVirgilCard *card in recipients) {
        VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:card.publicKey];
        [recipientPublicKeys addObject:publicKey];
    }
    
    return [self.context.crypto signThenEncryptData:data withPrivateKey:self.privateKey forRecipients:recipientPublicKeys error:errorPtr];
}

- (NSData *)signThenEncryptString:(NSString *)string forRecipients:(NSArray<VSSVirgilCard *> *)recipients error:(NSError **)errorPtr {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray<VSSPublicKey *> *recipientPublicKeys = [[NSMutableArray alloc] initWithCapacity:recipients.count];
    for (VSSVirgilCard *card in recipients) {
        VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:card.publicKey];
        [recipientPublicKeys addObject:publicKey];
    }
    
    return [self.context.crypto signThenEncryptData:data withPrivateKey:self.privateKey forRecipients:recipientPublicKeys error:errorPtr];
}

- (NSData *)decryptThenVerifyData:(NSData *)data from:(VSSVirgilCard *)card error:(NSError * __nullable * __nullable)errorPtr {
    VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:card.publicKey];
    
    return [self.context.crypto decryptThenVerifyData:data withPrivateKey:self.privateKey usingSignerPublicKey:publicKey error:errorPtr];
}

- (NSData *)decryptThenVerifyBase64String:(NSString *)base64String from:(VSSVirgilCard *)card error:(NSError **)errorPtr {
    VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:card.publicKey];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
    return [self.context.crypto decryptThenVerifyData:data withPrivateKey:self.privateKey usingSignerPublicKey:publicKey error:errorPtr];
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
