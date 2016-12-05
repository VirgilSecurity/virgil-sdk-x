//
//  VSSVirgilAuthorityKey.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSVirgilBaseKeyPrivate.h"
#import "VSSVirgilAuthorityKey.h"
#import "VSSVirgilConfig.h"

@interface VSSVirgilAuthorityKey ()

@property (nonatomic) NSString * __nonnull appId;

- (instancetype __nullable)initWithData:(NSData * __nonnull)data password:(NSString * __nullable)password forAppId:(NSString * __nonnull)appId NS_DESIGNATED_INITIALIZER;

@end

@implementation VSSVirgilAuthorityKey

- (instancetype)initWithData:(NSData *)data password:(NSString *)password forAppId:(NSString *)appId {
    id<VSSCrypto> crypto = VSSVirgilConfig.sharedInstance.crypto;
    
    VSSPrivateKey *privateKey = [crypto importPrivateKeyFromData:data withPassword:password];
    
    if (privateKey == nil)
        return nil;
    
    VSSPublicKey *publicKey = [crypto extractPublicKeyFromPrivateKey:privateKey];
    if (publicKey == nil)
        return nil;
    
    VSSKeyPair *keyPair = [[VSSKeyPair alloc] initWithPrivateKey:privateKey publicKey:publicKey];
    if (keyPair == nil)
        return nil;
    
    self = [super initWithKeyPair:keyPair];
    
    if (self) {
        _appId = [appId copy];
    }
    
    return self;
}

+ (instancetype)virgilAuthorityKeyWithData:(NSData *)data password:(NSString *)password forAppId:(NSString *)appId {
    return [[self alloc] initWithData:data password:password forAppId:appId];
}

+ (instancetype)virgilAuthorityKeyWithURL:(NSURL *)url password:(NSString *)password forAppId:(NSString *)appId {
    return [[self alloc] initWithData:[NSData dataWithContentsOfURL:url]];
}

- (BOOL)signRequest:(id<VSSSignable>)request error:(NSError **)errorPtr {
    id<VSSRequestSigner> signer = VSSVirgilConfig.sharedInstance.requestSigner;
    
    return [signer authoritySignRequest:request forAppId:self.appId withPrivateKey:self.keyPair.privateKey error:errorPtr];
}

@end
