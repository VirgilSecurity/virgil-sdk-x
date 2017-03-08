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
#import "VSSCardValidator.h"

@implementation VSSVirgilApiContext

- (instancetype)init {
    return [self initWithToken:nil];
}

- (instancetype)initWithToken:(NSString *)token credentials:(id<VSSCredentials>)credentials cardVerifiers:(NSArray<VSSCardVerifierInfo *> *)cardVerifiers {
    self = [super init];
    
    if (self) {
        _credentials = credentials;
        VSSCrypto *crypto = [[VSSCrypto alloc] init];
        
        VSSServiceConfig *serviceConfig = [VSSServiceConfig serviceConfigWithToken:token];
        VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:crypto];
        // FIXME (cardVerrfiers = nil)
        for (VSSCardVerifierInfo *info in cardVerifiers) {
            BOOL success = [validator addVerifierWithId:info.cardId publicKeyData:info.publicKeyData];
            if (!success)
                return nil;
        }
        serviceConfig.cardValidator = validator;
        
        _client = [[VSSClient alloc] initWithServiceConfig:serviceConfig];
        _crypto = crypto;
        _deviceManager = [[VSSDeviceManager alloc] init];
        _keyStorage = [[VSSKeyStorage alloc] init];
        _requestSigner = [[VSSRequestSigner alloc] initWithCrypto:crypto];
    }
    
    return self;
}

- (instancetype)initWithToken:(NSString *)token {
    return [self initWithToken:token credentials:nil cardVerifiers:nil];
}

@end
