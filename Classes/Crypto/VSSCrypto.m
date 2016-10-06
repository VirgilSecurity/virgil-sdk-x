//
//  VSSCrypto.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCrypto.h"
#import "VSSCryptoPrivate.h"
#import "VSSKeyPairPrivate.h"
#import "VSSPublicKeyPrivate.h"
#import "VSSPrivateKeyPrivate.h"

@import VirgilCrypto;

@implementation VSSCrypto

- (VSSKeyPair *)generateKey {
    VSCKeyPair *keyPair = [[VSCKeyPair alloc] init];
    
    NSData *keyPairId = [self computeHashForPublicKey:keyPair.publicKey];
    if ([keyPairId length] == 0)
        return nil;
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:keyPair.privateKey identifier:keyPairId];
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:keyPair.publicKey identifier:keyPairId];
    
    return [[VSSKeyPair alloc] initWithPrivateKey:privateKey publicKey:publicKey];
}

- (VSSPrivateKey *)importPrivateKey:(NSData *)keyData password:(NSString *)password {
    if ([keyData length] == 0)
        return nil;

    NSData *privateKeyData = ([password length] == 0) ?
        [VSCKeyPair privateKeyToDER:keyData] : [VSCKeyPair decryptPrivateKey:keyData privateKeyPassword:password];
    
    if ([privateKeyData length] == 0)
        return nil;

    NSData *publicKey = [VSCKeyPair extractPublicKeyWithPrivateKey:privateKeyData privateKeyPassword:nil];
    if ([publicKey length] == 0)
        return nil;

    NSData *keyIdentifier = [self computeHashForPublicKey:publicKey];
    if ([keyIdentifier length] == 0)
        return nil;
    
    NSData *exportedPrivateKeyData = [VSCKeyPair privateKeyToDER:privateKeyData];
    if ([exportedPrivateKeyData length] == 0)
        return nil;
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:exportedPrivateKeyData identifier:keyIdentifier];
    
    return privateKey;
}

- (VSSPublicKey *)importPublicKey:(NSData *)keyData {
    NSData *keyIdentifier = [self computeHashForPublicKey:keyData];
    if ([keyData length] == 0)
        return nil;

    NSData *exportedPublicKey = [VSCKeyPair publicKeyToDER:keyData];
    if ([exportedPublicKey length] == 0)
        return nil;
    
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:exportedPublicKey identifier:keyIdentifier];
    if (publicKey == nil)
        return nil;
    
    return publicKey;
}

- (NSData *)exportPrivateKey:(VSSPrivateKey *)privateKey password:(NSString *)password {
    if ([password length] == 0)
        return [VSCKeyPair privateKeyToDER:privateKey.key];
    
    NSData *encryptedPrivateKeyData = [VSCKeyPair encryptPrivateKey:privateKey.key privateKeyPassword:password];
    
    return [VSCKeyPair privateKeyToDER:encryptedPrivateKeyData privateKeyPassword:password];
}

- (NSData *)exportPublicKey:(VSSPublicKey *)publicKey {
    return [VSCKeyPair publicKeyToDER:publicKey.key];
}

- (VSSPublicKey *)extractPublicKeyFromPrivateKey:(VSSPrivateKey *)privateKey {
    NSData *publicKeyData = [VSCKeyPair extractPublicKeyWithPrivateKey:privateKey.key privateKeyPassword:nil];
    if ([publicKeyData length] == 0)
        return nil;
    
    NSData *exportedPublicKey = [VSCKeyPair publicKeyToDER:publicKeyData];
    if ([exportedPublicKey length] == 0)
        return nil;
    
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:exportedPublicKey identifier:privateKey.identifier];
    
    return publicKey;
}

- (NSData *)encryptData:(NSData *)data forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCCryptor *cipher = [[VSCCryptor alloc] init];
    
    NSError *error;
    for (VSSPublicKey *publicKey in recipients) {
        [cipher addKeyRecipient:publicKey.identifier publicKey:publicKey.key error:&error];
        
        if (error != nil) {
            if (errorPtr != nil)
                *errorPtr = error;
            return nil;
        }
    }

    NSData *encryptedData = [cipher encryptData:data embedContentInfo:YES error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }

    return encryptedData;
}

- (void)encryptStream:(NSInputStream *)stream outputStream:(NSOutputStream *)outputStream forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCChunkCryptor *cipher = [[VSCChunkCryptor alloc] init];

    NSError *error;
    for (VSSPublicKey *publicKey in recipients) {
        [cipher addKeyRecipient:publicKey.identifier publicKey:publicKey.key error:&error];
        if (error != nil) {
            if (errorPtr != nil)
                *errorPtr = error;
            return;
        }
    }

    [cipher encryptDataFromStream:stream toStream:outputStream error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return;
    }
}

- (bool)verifyData:(NSData *)data signature:(NSData *)signature signerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSError *error;
    BOOL verified = [signer verifySignature:signature data:data publicKey:signerPublicKey.key error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return verified;
}

- (bool)verifyStream:(NSInputStream *)inputStream signature:(NSData *)signature signerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCStreamSigner *signer = [[VSCStreamSigner alloc] init];
    
    NSError *error;
    BOOL verified = [signer verifySignature:signature fromStream:inputStream publicKey:signerPublicKey.key error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return verified;
}

- (NSData *)decryptData:(NSData *)data privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCCryptor *cipher = [[VSCCryptor alloc] init];

    NSError *error;
    NSData *decryptedData = [cipher decryptData:data recipientId:privateKey.identifier privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return decryptedData;
}

- (void)decryptStream:(NSInputStream * __nonnull)inputStream outputStream:(NSOutputStream * __nonnull)outputStream privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    VSCChunkCryptor *cipher = [[VSCChunkCryptor alloc] init];

    NSError *error;
    [cipher decryptFromStream:inputStream toStream:outputStream recipientId:privateKey.identifier privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
    }
}

- (NSData *)signData:(NSData *)data privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSError *error;
    NSData *signature = [signer signData:data privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return signature;
}

- (NSData *)signStream:(NSInputStream *)stream privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCStreamSigner *signer = [[VSCStreamSigner alloc] init];
    
    NSError *error;
    NSData *signature = [signer signStreamData:stream privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return signature;
}

- (VSSFingerprint * __nonnull)calculateFingerprintOfData:(NSData * __nonnull)data {
    NSData *hash = [self computeHashForData:data withAlgorithm:VSSHashAlgorithmSHA256];
    return [[VSSFingerprint alloc] initWithValue:hash];
}

- (NSData * __nonnull)computeHashForData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm {
    VSCAlgorithm cryptoAlgorithm;
    switch (algorithm) {
        case VSSHashAlgorithmMD5: cryptoAlgorithm = VSCAlgorithmMD5; break;
        case VSSHashAlgorithmSHA1: cryptoAlgorithm = VSCAlgorithmSHA1; break;
        case VSSHashAlgorithmSHA224: cryptoAlgorithm = VSCAlgorithmSHA224; break;
        case VSSHashAlgorithmSHA256: cryptoAlgorithm = VSCAlgorithmSHA256; break;
        case VSSHashAlgorithmSHA384: cryptoAlgorithm = VSCAlgorithmSHA384; break;
        case VSSHashAlgorithmSHA512: cryptoAlgorithm = VSCAlgorithmSHA512; break;
    }
    VSCHash *hash = [[VSCHash alloc] initWithAlgorithm:cryptoAlgorithm];
    return [hash hash:data];
}

- (NSData *)computeHashForPublicKey:(NSData *)publicKey {
    NSData *publicKeyDER = [VSCKeyPair publicKeyToDER:publicKey];
    return [self computeHashForData:publicKeyDER withAlgorithm:VSSHashAlgorithmSHA256];
}

@end
