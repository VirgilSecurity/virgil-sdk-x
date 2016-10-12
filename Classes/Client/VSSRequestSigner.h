//
//  VSSRequestSigner.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCryptoProtocol.h"
#import "VSSPrivateKey.h"
#import "VSSPublicKey.h"
#import "VSSSignedData.h"

@interface VSSRequestSigner : NSObject

@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;

- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nonnull)crypto;

- (instancetype __nonnull)init NS_UNAVAILABLE;

- (BOOL)applicationSignRequest:(VSSSignedData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

- (BOOL)authoritySignRequest:(VSSSignedData * __nonnull)data appId:(NSString * __nonnull)appId withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

@end
