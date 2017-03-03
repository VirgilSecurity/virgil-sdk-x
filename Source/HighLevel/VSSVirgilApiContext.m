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

@implementation VSSVirgilApiContext

- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        _credentials = nil;
        _token = [token copy];
        _client = [[VSSClient alloc] initWithApplicationToken:token];
        _crypto = [[VSSCrypto alloc] init];
        _deviceManager = [[VSSDeviceManager alloc] init];
        _keyStorage = [[VSSKeyStorage alloc] init];
    }
    
    return self;
}

@end
