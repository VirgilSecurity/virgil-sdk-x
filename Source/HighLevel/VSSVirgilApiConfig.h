//
//  VSSVirgilApiConfig.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCryptoProtocol.h"
#import "VSSDeviceManagerProtocol.h"
#import "VSSKeyStorageProtocol.h"

@class VSSCredentials;
@class VSSCardVerifierInfo;

@interface VSSVirgilApiConfig : NSObject

@property (nonatomic, readonly) NSString * __nonnull accessToken;
@property (nonatomic, readonly) VSSCredentials * __nonnull credentials;
@property (nonatomic, readonly) NSArray<VSSCardVerifierInfo *> * __nonnull cardVerifiers;
@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;
@property (nonatomic, readonly) id<VSSDeviceManager> __nonnull deviceManager;
@property (nonatomic, readonly) id<VSSKeyStorage> __nonnull keyStorage;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
