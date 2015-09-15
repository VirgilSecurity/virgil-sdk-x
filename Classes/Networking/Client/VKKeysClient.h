//
//  VKKeysClient.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirgilFrameworkiOS/VFClient.h>
#import "VKIdBundle.h"

@class VKPublicKey;
@class VKUserData;
@class VKActionToken;

@class VCKeyPair;

@interface VKKeysClient : VFClient

- (void)createPublicKey:(VKPublicKey *)publicKey privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler;
- (void)getPublicKeyId:(GUID *)publicKeyId completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler;
- (void)updatePublicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword newKeyPair:(VCKeyPair *)keyPair newKeyPassword:(NSString *)newKeyPassword completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler;
- (void)deletePublicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKActionToken *actionToken, NSError *error))completionHandler;
- (void)resetPublicKeyId:(GUID *)publicKeyId keyPair:(VCKeyPair *)keyPair keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKActionToken *actionToken, NSError *error))completionHandler;
- (void)persistPublicKeyId:(GUID *)publicKeyId actionToken:(VKActionToken *)actionToken completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler;

// Signed version
- (void)searchPublicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler;
// Unsigned version
- (void)searchPublicKeyUserIdValue:(NSString *)value completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler;

// Signed version
- (void)createUserData:(VKUserData *)userData publicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)password completionHandler:(void(^)(VKUserData *uData, NSError *error))completionHandler;
// Unsigned version
- (void)createUserData:(VKUserData *)userData publicKeyId:(GUID *)publicKeyId completionHandler:(void(^)(VKUserData *uData, NSError *error))completionHandler;

- (void)deleteUserDataId:(GUID *)userDataId publicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(NSError *error))completionHandler;
- (void)persistUserDataId:(GUID *)userDataId confirmationCode:(NSString *)code completionHandler:(void(^)(NSError *error))completionHandler;
- (void)resendConfirmationUserDataId:(GUID *)userDataId publicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(NSError *error))completionHandler;

@end
