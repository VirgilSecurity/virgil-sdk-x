//
//  VSSVirgilBaseKey.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilBaseKeyPrivate.h"
#import "VSSVirgilConfig.h"

@implementation VSSVirgilBaseKey

- (instancetype)initWithKeyPair:(VSSKeyPair *)keyPair {
    self = [super init];
    if (self) {
        _keyPair = [keyPair copy];
    }
    
    return self;
}

- (NSData *)generateSignatureForData:(NSData *)data error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    return [crypto generateSignatureForData:data withPrivateKey:self.keyPair.privateKey error:errorPtr];
}

- (NSData *)decryptData:(NSData *)data error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    return [crypto decryptData:data withPrivateKey:self.keyPair.privateKey error:errorPtr];
}

- (NSData *)signAndEncryptData:(NSData *)data forRecipients:(NSArray<VSSVirgilCard *> *)recipients error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    NSMutableArray<VSSPublicKey *> *publicKeys = [[NSMutableArray alloc] initWithCapacity:recipients.count];
    
    for (VSSVirgilCard *card in recipients) {
        [publicKeys addObject:[crypto importPublicKeyFromData:card.publicKey]];
    }
    
    return [crypto signAndEncryptData:data withPrivateKey:self.keyPair.privateKey forRecipients:publicKeys error:errorPtr];
}

- (NSData *)decryptAndVerifyData:(NSData *)data fromSigner:(VSSVirgilCard *)signer error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    VSSPublicKey *publicKey = [crypto importPublicKeyFromData:signer.publicKey];
    
    return [crypto decryptAndVerifyData:data withPrivateKey:self.keyPair.privateKey usingSignerPublicKey:publicKey error:errorPtr];
}

- (BOOL)signRequest:(id<VSSSignable>)request error:(NSError **)errorPtr {
    NSAssert(NO, @"Subclasses must override this method");
    return NO;
}

@end
