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

@interface VSSVirgilApiContext ()

@property (nonatomic) NSString * __nullable token;
@property (nonatomic) id<VSSCardValidator> __nullable cardValidator;

@end

@implementation VSSVirgilApiContext

@synthesize client = _client;
@synthesize deviceManager = _deviceManager;
@synthesize keyStorage = _keyStorage;
@synthesize requestSigner = _requestSigner;

- (instancetype)init {
    return [self initWithToken:nil];
}

- (instancetype)initWithCrypto:(id<VSSCrypto>)crypto token:(NSString *)token credentials:(id<VSSCredentials>)credentials cardVerifiers:(NSArray<VSSCardVerifierInfo *> *)cardVerifiers {
    self = [super init];
    
    if (self) {
        if (crypto == nil) {
            crypto = [[VSSCrypto alloc] init];
        }
        _crypto = crypto;
        
        _credentials = credentials;
        _token = [token copy];
        
        VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:crypto];
        // FIXME (cardVerrfiers = nil)
        for (VSSCardVerifierInfo *info in cardVerifiers) {
            BOOL success = [validator addVerifierWithId:info.cardId publicKeyData:info.publicKeyData];
            if (!success)
                return nil;
        }
        _cardValidator = validator;
    }
    
    return self;
}

- (instancetype)initWithToken:(NSString *)token {
    return [self initWithCrypto:[[VSSCrypto alloc] init] token:token credentials:nil cardVerifiers:nil];
}

- (VSSClient *)client {
    @synchronized (self) {
        if (_client == nil) {
            VSSServiceConfig *serviceConfig = [VSSServiceConfig serviceConfigWithToken:self.token];
            serviceConfig.cardValidator = self.cardValidator;
            
            _client = [[VSSClient alloc] initWithServiceConfig:serviceConfig];
        }
        
        return _client;
    }
}

- (void)setClient:(VSSClient *)client {
    @synchronized (self) {
        _client = client;
    }
}

- (id<VSSDeviceManager>)deviceManager {
    @synchronized (self) {
        if (_deviceManager == nil) {
            _deviceManager = [[VSSDeviceManager alloc] init];
        }
        
        return _deviceManager;
    }
}

- (void)setDeviceManager:(id<VSSDeviceManager>)deviceManager {
    @synchronized (self) {
        _deviceManager = deviceManager;
    }
}

- (id<VSSKeyStorage>)keyStorage {
    @synchronized (self) {
        if (_keyStorage == nil) {
            _keyStorage = [[VSSKeyStorage alloc] init];
        }
        
        return _keyStorage;
    }
}

- (void)setKeyStorage:(id<VSSKeyStorage>)keyStorage {
    @synchronized (self) {
        _keyStorage = keyStorage;
    }
}

- (id<VSSRequestSigner>)requestSigner {
    @synchronized (self) {
        if (_requestSigner == nil) {
            _requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
        }
        
        return _requestSigner;
    }
}

- (void)setRequestSigner:(id<VSSRequestSigner>)requestSigner {
    @synchronized (self) {
        _requestSigner = requestSigner;
    }
}

@end
