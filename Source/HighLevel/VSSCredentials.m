//
//  VSSCredentials.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCredentials.h"

@implementation VSSCredentials

@synthesize appId = _appId;
@synthesize appKey = _appKey;

- (NSString *)getAppId {
    return self.appId;
}

- (VSSPrivateKey *)getAppKey {
    return self.appKey;
}

- (instancetype __nullable)initWithCrypto:(id<VSSCrypto>)crypto appKeyData:(NSData *)appKeyData appKeyPassword:(NSString *)password appId:(NSString *)appId {
    self = [super init];
    if (self) {
        VSSPrivateKey *privateKey = [crypto importPrivateKeyFromData:appKeyData withPassword:password];
        if (privateKey == nil)
            return nil;
        _appKey = privateKey;
        _appId = [appId copy];
    }
    
    return self;
}

@end
