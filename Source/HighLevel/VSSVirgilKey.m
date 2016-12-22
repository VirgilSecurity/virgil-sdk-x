//
//  VSSVirgilKey.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKeyPrivate.h"
#import "VSSKeyPairPrivate.h"
#import "VSSVirgilConfig.h"
#import "VSSVirgilCardPrivate.h"
#import "VSSVirgilBaseKeyPrivate.h"

NSString *const kVSSVirgilKeyErrorDomain = @"VSSVirgilKeyErrorDomain";

@implementation VSSVirgilKey

- (instancetype)initWithName:(NSString *)name keyPair:(VSSKeyPair *)keyPair {
    self = [super initWithKeyPair:keyPair];
    if (self) {
        _keyName = [name copy];
    }
    
    return self;
}

+ (instancetype)virgilKeyWithName:(NSString *)name keyPair:(VSSKeyPair *)keyPair {
    VSSVirgilKey *key = [[self alloc] initWithName:name keyPair:keyPair];

    return key;
}

+ (instancetype)virgilKeyWithName:(NSString *)name {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    VSSKeyPair *keyPair = [crypto generateKeyPair];
    return [self virgilKeyWithName:name keyPair:keyPair];
}

- (NSData *)exportWithPassword:(NSString *)password {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    return [crypto exportPrivateKey:self.keyPair.privateKey withPassword:password];
}

- (VSSCreateCardRequest *)buildCreateCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType data:(NSDictionary<NSString *, NSString *> *)data error:(NSError **)errorPtr {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    id<VSSRequestSigner> signer = VSSVirgilConfig.sharedInstance.requestSigner;
    
    NSData *publicKey = [crypto exportPublicKey:self.keyPair.publicKey];
    
    VSSCreateCardRequest *request = [VSSCreateCardRequest createCardRequestWithIdentity:identity identityType:identityType publicKey:publicKey data:data];
    
    if (![signer selfSignRequest:request withPrivateKey:self.keyPair.privateKey error:errorPtr]) {
        return nil;
    }
    
    return request;
}

- (BOOL)signRequest:(id<VSSSignable>)request error:(NSError **)errorPtr {
    id<VSSRequestSigner> signer = VSSVirgilConfig.sharedInstance.requestSigner;
    
    return [signer selfSignRequest:request withPrivateKey:self.keyPair.privateKey error:errorPtr];
}

@end
