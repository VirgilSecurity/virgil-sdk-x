//
//  VSSVirgilConfig.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilConfig.h"
#import "VSSCrypto.h"
#import "VSSClient.h"
#import "VSSRequestSigner.h"
#import "VSSCardValidator.h"
#import "VSSKeyStorage.h"

@interface VSSVirgilConfig ()

- (instancetype __nonnull)initWithApplicationToken:(NSString * __nonnull)applicationToken;

@end

@implementation VSSVirgilConfig

static VSSVirgilConfig *_sharedInstance;

+ (instancetype)sharedInstance {
    return _sharedInstance;
}

+ (void)initializeWithApplicationToken:(NSString *)applicationToken {
    _sharedInstance = [[self alloc] initWithApplicationToken:applicationToken];
}

- (instancetype)initWithApplicationToken:(NSString *)applicationToken {
    self = [super init];
    if (self) {
        _crypto = [[VSSCrypto alloc] init];
        _requestSigner = [[VSSRequestSigner alloc] initWithCrypto:_crypto];
        _cardValidator = [[VSSCardValidator alloc] initWithCrypto:_crypto];
        _keyStorage = [[VSSKeyStorage alloc] init];
        _client = [[VSSClient alloc] initWithApplicationToken:applicationToken];
    }

    return self;
}

@end
