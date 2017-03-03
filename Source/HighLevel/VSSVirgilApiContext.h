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

@interface VSSVirgilApiContext : NSObject

@property (nonatomic) id<VSSCredentials> __nullable credentials;
@property (nonatomic) NSString * __nullable token;
@property (nonatomic, readonly) id<VSSClient> __nonnull client;
@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;
@property (nonatomic, readonly) id<VSSDeviceManager> __nonnull deviceManager;
@property (nonatomic, readonly) id<VSSKeyStorage> __nonnull keyStorage;

- (instancetype __nonnull)initWithToken:(NSString * __nullable)token;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
