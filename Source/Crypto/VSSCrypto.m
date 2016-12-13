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
#import "VSSRequestSigner.h"
#import "VSSCryptoCommonsPrivate.h"

static NSString * const kVSSCustomParamKeySignature = @"VIRGIL-DATA-SIGNATURE";

@import VirgilCrypto;

@implementation VSSCrypto

#pragma mark - Key processing

- (VSSKeyPair * __nonnull)wrapCryptoKeyPair:(VSCKeyPair * __nonnull)keyPair {
    NSData *keyPairId = [self computeHashForPublicKey:keyPair.publicKey];
    if (keyPairId.length == 0)
        return nil;
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:keyPair.privateKey identifier:keyPairId];
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:keyPair.publicKey identifier:keyPairId];
    
    return [[VSSKeyPair alloc] initWithPrivateKey:privateKey publicKey:publicKey];
}

- (VSSKeyPair *)generateKeyPair {
    return [self wrapCryptoKeyPair:[[VSCKeyPair alloc] init]];
}

- (VSSKeyPair * __nonnull)generateKeyPairOfType:(VSSKeyType)type {
    VSCKeyType cType = vss_mapKeyType(type);
    return [self wrapCryptoKeyPair:[[VSCKeyPair alloc] initWithKeyPairType:cType password:nil]];
}

- (VSSPrivateKey *)importPrivateKeyFromData:(NSData *)data withPassword:(NSString *)password {
    if (data.length == 0)
        return nil;

    NSData *privateKeyData = (password.length == 0) ?
        data : [VSCKeyPair decryptPrivateKey:data privateKeyPassword:password];
    
    if (privateKeyData.length == 0)
        return nil;

    NSData *publicKey = [VSCKeyPair extractPublicKeyWithPrivateKey:privateKeyData privateKeyPassword:nil];
    if (publicKey.length == 0)
        return nil;

    NSData *keyIdentifier = [self computeHashForPublicKey:publicKey];
    if (keyIdentifier.length == 0)
        return nil;
    
    NSData *exportedPrivateKeyData = [VSCKeyPair privateKeyToDER:privateKeyData];
    if (exportedPrivateKeyData.length == 0)
        return nil;
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:exportedPrivateKeyData identifier:keyIdentifier];
    
    return privateKey;
}

- (VSSPrivateKey *)importPrivateKeyFromData:(NSData *)data {
    return [self importPrivateKeyFromData:data withPassword:nil];
}

- (VSSPublicKey *)importPublicKeyFromData:(NSData *)data {
    if (data.length == 0)
        return nil;
    
    NSData *keyIdentifier = [self computeHashForPublicKey:data];

    NSData *exportedPublicKey = [VSCKeyPair publicKeyToDER:data];
    if (exportedPublicKey.length == 0)
        return nil;
    
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:exportedPublicKey identifier:keyIdentifier];
    
    return publicKey;
}

- (NSData *)exportPrivateKey:(VSSPrivateKey *)privateKey withPassword:(NSString *)password {
    if (password.length == 0)
        return [VSCKeyPair privateKeyToDER:privateKey.key];
    
    NSData *encryptedPrivateKeyData = [VSCKeyPair encryptPrivateKey:privateKey.key privateKeyPassword:password];
    
    return [VSCKeyPair privateKeyToDER:encryptedPrivateKeyData privateKeyPassword:password];
}

- (NSData *)exportPublicKey:(VSSPublicKey *)publicKey {
    return [VSCKeyPair publicKeyToDER:publicKey.key];
}

- (VSSPublicKey *)extractPublicKeyFromPrivateKey:(VSSPrivateKey *)privateKey {
    NSData *exportedPrivateKey = [self exportPrivateKey:privateKey withPassword:nil];
    NSData *publicKeyData = [VSCKeyPair extractPublicKeyWithPrivateKey:exportedPrivateKey privateKeyPassword:nil];
    if (publicKeyData.length == 0)
        return nil;
    
    NSData *exportedPublicKey = [VSCKeyPair publicKeyToDER:publicKeyData];
    if (exportedPublicKey.length == 0)
        return nil;
    
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:exportedPublicKey identifier:privateKey.identifier];
    
    return publicKey;
}

#pragma mark - Data processing

- (NSData *)encryptData:(NSData *)data forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCCryptor *cipher = [[VSCCryptor alloc] init];
    
    NSError *error;
    for (VSSPublicKey *publicKey in recipients) {
        NSData *publicKeyData = [self exportPublicKey:publicKey];
        [cipher addKeyRecipient:publicKey.identifier publicKey:publicKeyData error:&error];
        
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

- (BOOL)encryptStream:(NSInputStream *)stream toOutputStream:(NSOutputStream *)outputStream forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCChunkCryptor *cipher = [[VSCChunkCryptor alloc] init];

    NSError *error;
    for (VSSPublicKey *publicKey in recipients) {
        NSData *publicKeyData = [self exportPublicKey:publicKey];
        [cipher addKeyRecipient:publicKey.identifier publicKey:publicKeyData error:&error];
        if (error != nil) {
            if (errorPtr != nil)
                *errorPtr = error;
            return NO;
        }
    }

    [cipher encryptDataFromStream:stream toStream:outputStream error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return YES;
}

- (BOOL)verifyData:(NSData *)data withSignature:(NSData *)signature usingSignerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSError *error;
    NSData *signerPublicKeyData = [self exportPublicKey:signerPublicKey];
    BOOL verified = [signer verifySignature:signature data:data publicKey:signerPublicKeyData error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return verified;
}

- (BOOL)verifyStream:(NSInputStream *)stream signature:(NSData *)signature usingSignerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCStreamSigner *signer = [[VSCStreamSigner alloc] init];
    
    NSError *error;
    NSData *signerPublicKeyData = [self exportPublicKey:signerPublicKey];
    BOOL verified = [signer verifySignature:signature fromStream:stream publicKey:signerPublicKeyData error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return verified;
}

- (NSData *)decryptData:(NSData *)data withPrivateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCCryptor *cipher = [[VSCCryptor alloc] init];

    NSError *error;
    NSData *privateKeyData = [self exportPrivateKey:privateKey withPassword:nil];
    NSData *decryptedData = [cipher decryptData:data recipientId:privateKey.identifier privateKey:privateKeyData keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return decryptedData;
}

- (BOOL)decryptStream:(NSInputStream *)stream toOutputStream:(NSOutputStream *)outputStream withPrivateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCChunkCryptor *cipher = [[VSCChunkCryptor alloc] init];

    NSError *error;
    NSData *privateKeyData = [self exportPrivateKey:privateKey withPassword:nil];
    [cipher decryptFromStream:stream toStream:outputStream recipientId:privateKey.identifier privateKey:privateKeyData keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return YES;
}

- (NSData *)signThenEncryptData:(NSData *)data withPrivateKey:(VSSPrivateKey *)privateKey forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSData *privateKeyData = [self exportPrivateKey:privateKey withPassword:nil];
    
    NSError *error;
    
    NSData *signature = [signer signData:data privateKey:privateKeyData keyPassword:nil error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    VSCCryptor *cryptor = [[VSCCryptor alloc] init];

    [cryptor setData:signature forKey:kVSSCustomParamKeySignature error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    for (VSSPublicKey *publicKey in recipients) {
        NSData *publicKeyData = [self exportPublicKey:publicKey];
        NSError *error;
        [cryptor addKeyRecipient:publicKey.identifier publicKey:publicKeyData error:&error];
        if (error != nil) {
            if (errorPtr != nil)
                *errorPtr = error;
            return nil;
        }
    }
    
    NSData *encryptedData = [cryptor encryptData:data embedContentInfo:YES error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return encryptedData;
}

- (NSData *)decryptAndVerifyData:(NSData *)data withPrivateKey:(VSSPrivateKey *)privateKey usingSignerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCCryptor *cryptor = [[VSCCryptor alloc] init];
    
    NSError *error;
    NSData *privateKeyData = [self exportPrivateKey:privateKey withPassword:nil];
    NSData *decryptedData = [cryptor decryptData:data recipientId:privateKey.identifier privateKey:privateKeyData keyPassword:nil error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    NSData *signature = [cryptor dataForKey:kVSSCustomParamKeySignature error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    VSCSigner *signer = [[VSCSigner alloc] init];
    NSData *publicKeyData = [self exportPublicKey:signerPublicKey];
    BOOL isVerified = [signer verifySignature:signature data:decryptedData publicKey:publicKeyData error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    if (!isVerified)
        return nil;
    
    return decryptedData;
}

#pragma mark - Signatures

- (NSData *)generateSignatureForData:(NSData *)data withPrivateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSError *error;
    NSData *exportedPrivateKey = [self exportPrivateKey:privateKey withPassword:nil];
    NSData *signature = [signer signData:data privateKey:exportedPrivateKey keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return signature;
}

- (NSData *)generateSignatureForStream:(NSInputStream *)stream withPrivateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCStreamSigner *signer = [[VSCStreamSigner alloc] init];
    
    NSError *error;
    NSData *exportedPrivateKey = [self exportPrivateKey:privateKey withPassword:nil];
    NSData *signature = [signer signStreamData:stream privateKey:exportedPrivateKey keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return signature;
}

- (VSSFingerprint * __nonnull)calculateFingerprintForData:(NSData * __nonnull)data {
    NSData *hash = [self computeHashForData:data withAlgorithm:VSSHashAlgorithmSHA256];
    return [[VSSFingerprint alloc] initWithValue:hash];
}

- (NSData * __nonnull)computeHashForData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm {
    VSCHashAlgorithm cryptoAlgorithm;
    switch (algorithm) {
        case VSSHashAlgorithmMD5: cryptoAlgorithm = VSCHashAlgorithmMD5; break;
        case VSSHashAlgorithmSHA1: cryptoAlgorithm = VSCHashAlgorithmSHA1; break;
        case VSSHashAlgorithmSHA224: cryptoAlgorithm = VSCHashAlgorithmSHA224; break;
        case VSSHashAlgorithmSHA256: cryptoAlgorithm = VSCHashAlgorithmSHA256; break;
        case VSSHashAlgorithmSHA384: cryptoAlgorithm = VSCHashAlgorithmSHA384; break;
        case VSSHashAlgorithmSHA512: cryptoAlgorithm = VSCHashAlgorithmSHA512; break;
    }
    VSCHash *hash = [[VSCHash alloc] initWithAlgorithm:cryptoAlgorithm];
    return [hash hash:data];
}

- (NSData *)computeHashForPublicKey:(NSData *)publicKey {
    NSData *publicKeyDER = [VSCKeyPair publicKeyToDER:publicKey];
    return [self computeHashForData:publicKeyDER withAlgorithm:VSSHashAlgorithmSHA256];
}

@end
