//
//  VSSVirgilConfig.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSCryptoProtocol.h"
#import "VSSCardValidatorProtocol.h"
#import "VSSRequestSignerProtocol.h"
#import "VSSKeyStorageProtocol.h"
#import "VSSClientProtocol.h"

@interface VSSVirgilConfig : NSObject

@property (nonatomic, copy) id<VSSCrypto> __nonnull crypto;
@property (nonatomic, copy) id<VSSCardValidator> __nonnull cardValidator;
@property (nonatomic, copy) id<VSSRequestSigner> __nonnull requestSigner;
@property (nonatomic, copy) id<VSSKeyStorage> __nonnull keyStorage;
@property (nonatomic, copy) id<VSSClient> __nonnull client;

+ (instancetype __nonnull)sharedInstance;

+ (void)initializeWithApplicationToken:(NSString * __nonnull)applicationToken;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
