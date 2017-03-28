//
//  VSSCredentials.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCredentials.h"

@interface VSSCredentials ()

@property (nonatomic, readonly) NSString * __nonnull password;
@property (nonatomic, readonly) NSData * __nonnull appKeyData;

@end

@implementation VSSCredentials

@synthesize appId = _appId;

- (NSString *)getAppId {
    return self.appId;
}

- (VSSPrivateKey *)getAppKeyUsingCrypto:(id<VSSCrypto>)crypto {
    VSSPrivateKey *privateKey = [crypto importPrivateKeyFromData:self.appKeyData withPassword:self.password];
    return privateKey;
}

- (instancetype)initWithAppKeyData:(NSData *)appKeyData appKeyPassword:(NSString *)password appId:(NSString *)appId {
    self = [super init];
    if (self) {
        _password = [password copy];
        _appKeyData = [appKeyData copy];
        _appId = [appId copy];
    }
    
    return self;
}

@end
