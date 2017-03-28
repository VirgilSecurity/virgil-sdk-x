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
    
    return [self generateSignatureForData:data error:errorPtr];
}

- (NSData *)decryptData:(NSData *)data error:(NSError **)errorPtr {
    return [self.context.crypto decryptData:data withPrivateKey:self.privateKey error:errorPtr];
}

- (NSData *)decryptBase64String:(NSString *)base64String error:(NSError **)errorPtr {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];

    return [self decryptData:data error:errorPtr];
}

- (NSData *)signThenEncryptData:(NSData *)data forRecipients:(NSArray<VSSVirgilCard *> *)recipients error:(NSError **)errorPtr {
    NSMutableArray<VSSPublicKey *> *recipientPublicKeys = [[NSMutableArray alloc] initWithCapacity:recipients.count];
    for (VSSVirgilCard *card in recipients) {
        [recipientPublicKeys addObject:card.publicKey];
    }
    
    return [self.context.crypto signThenEncryptData:data withPrivateKey:self.privateKey forRecipients:recipientPublicKeys error:errorPtr];
}

- (NSData *)signThenEncryptString:(NSString *)string forRecipients:(NSArray<VSSVirgilCard *> *)recipients error:(NSError **)errorPtr {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self signThenEncryptData:data forRecipients:recipients error:errorPtr];
}

- (NSData *)decryptThenVerifyData:(NSData *)data from:(VSSVirgilCard *)card error:(NSError * __nullable * __nullable)errorPtr {
    return [self.context.crypto decryptThenVerifyData:data withPrivateKey:self.privateKey usingSignerPublicKey:card.publicKey error:errorPtr];
}

- (NSData *)decryptThenVerifyData:(NSData *)data fromOneOf:(NSArray<VSSVirgilCard *> *)cards error:(NSError **)errorPtr {
    NSMutableArray *publicKeys = [[NSMutableArray alloc] initWithCapacity:cards.count];
    for (VSSVirgilCard *card in cards) {
        [publicKeys addObject:card.publicKey];
    }
    
    return [self.context.crypto decryptThenVerifyData:data withPrivateKey:self.privateKey usingOneOfSignersPublicKeys:publicKeys error:errorPtr];
}

- (NSData *)decryptThenVerifyBase64String:(NSString *)base64String from:(VSSVirgilCard *)card error:(NSError **)errorPtr {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
    return [self decryptThenVerifyData:data from:card error:errorPtr];
}

- (NSData *)decryptThenVerifyBase64String:(NSString *)base64String fromOneOf:(NSArray<VSSVirgilCard *> *)cards error:(NSError **)errorPtr {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
    return [self decryptThenVerifyData:data fromOneOf:cards error:errorPtr];
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
