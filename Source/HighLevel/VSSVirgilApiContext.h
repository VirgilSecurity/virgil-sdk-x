//
//  VSSVirgilApiContext.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCredentialsProtocol.h"
#import "VSSClientProtocol.h"
#import "VSSCryptoProtocol.h"
#import "VSSDeviceManagerProtocol.h"
#import "VSSKeyStorageProtocol.h"
#import "VSSRequestSignerProtocol.h"

@interface VSSVirgilApiContext : NSObject

@property (nonatomic) id<VSSCredentials> __nullable credentials;
@property (nonatomic) id<VSSClient> __nonnull client;
@property (nonatomic) id<VSSCrypto> __nonnull crypto;
@property (nonatomic) id<VSSDeviceManager> __nonnull deviceManager;
@property (nonatomic) id<VSSKeyStorage> __nonnull keyStorage;
@property (nonatomic) id<VSSRequestSigner> __nonnull requestSigner;

- (instancetype __nonnull)initWithToken:(NSString * __nullable)token;

- (instancetype __nonnull)initWithToken:(NSString * __nullable)token credentials:(id<VSSCredentials> __nullable)credentials NS_DESIGNATED_INITIALIZER;

@end
