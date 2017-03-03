//
//  VSSCardsManager.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardsManager.h"
#import "VSSVirgilCardPrivate.h"
#import "VSSCardsManagerPrivate.h"
#import "VSSCreateApplicationCardRequest.h"
#import "VSSCreateGlobalCardRequest.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSRequestSigner.h"
#import "VSSVirgilKeyPrivate.h"
#import "VSSVirgilIdentityPrivate.h"
#import "VSSVirgilGlobalIdentityPrivate.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCardsManager

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    
    return self;
}

- (VSSVirgilCard *)createCardWithIdentity:(VSSVirgilIdentity *)identity ownerKey:(VSSVirgilKey *)ownerKey data:(NSDictionary<NSString *, NSString *> *)data error:(NSError **)errorPtr {
    NSString *device = [self.context.deviceManager getDeviceModel];
    NSString *deviceName = [self.context.deviceManager getDeviceName];
    NSData *publicKeyData = [ownerKey exportPublicKey];
    
    VSSCreateCardRequest *request;
    VSSVirgilGlobalIdentity *globalIdentity = [identity as:[VSSVirgilGlobalIdentity class]];
    
    if (globalIdentity != nil) {
        request = [VSSCreateGlobalCardRequest createGlobalCardRequestWithIdentity:identity.value identityType:identity.type validationToken:globalIdentity.token publicKeyData:publicKeyData data:data device:device deviceName:deviceName];
    }
    else {
        request = [VSSCreateApplicationCardRequest createApplicationCardRequestWithIdentity:identity.value identityType:identity.type publicKeyData:publicKeyData data:data device:device deviceName:deviceName];
    }
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.context.crypto];
    if (!([signer selfSignRequest:request withPrivateKey:ownerKey.privateKey error:errorPtr]))
        return nil;
    
    return [[VSSVirgilCard alloc] initWithContext:self.context request:request];
}

- (void)publishCard:(VSSVirgilCard *)card completion:(void (^)(NSError *))callback; {
    [card publishWithCompletion:callback];
}

@end
