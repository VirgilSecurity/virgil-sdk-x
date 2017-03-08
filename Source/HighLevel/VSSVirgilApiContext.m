//
//  VSSVirgilApiContext.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilApiContext.h"
#import "VSSClient.h"
#import "VSSCrypto.h"
#import "VSSDeviceManager.h"
#import "VSSKeyStorage.h"
#import "VSSRequestSigner.h"

@implementation VSSVirgilApiContext

- (instancetype)init {
    return [self initWithToken:nil];
}

- (instancetype)initWithToken:(NSString *)token credentials:(id<VSSCredentials>)credentials {
    self = [super init];
    
    if (self) {
        _credentials = credentials;
        _client = [[VSSClient alloc] initWithApplicationToken:token];
        _crypto = [[VSSCrypto alloc] init];
        _deviceManager = [[VSSDeviceManager alloc] init];
        _keyStorage = [[VSSKeyStorage alloc] init];
        _requestSigner = [[VSSRequestSigner alloc] initWithCrypto:_crypto];
    }
    
    return self;
}

- (instancetype)initWithToken:(NSString *)token {
    return [self initWithToken:token credentials:nil];
}

@end
