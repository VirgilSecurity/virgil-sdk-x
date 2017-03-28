//
//  VSSVirgilCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCardPrivate.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSVirgilApi.h"
#import "VSSCardResponsePrivate.h"

@implementation VSSVirgilCard

- (instancetype)initWithContext:(VSSVirgilApiContext *)context request:(VSSCreateCardRequest *)request {
    self = [super init];
    if (self) {
        _context = context;
        _request = request;
        
        VSSFingerprint *fingerprint = [context.crypto calculateFingerprintForData:request.snapshot];
        _calculatedIdentifier = [fingerprint hexValue];
    }
    
    return self;
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context card:(VSSCard *)card {
    self = [super init];
    if (self) {
        _context = context;
        _card = card;
    }
    
    return self;
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context data:(NSString *)data {
    VSSCard *card = [[VSSCard alloc] initWithData:data];
    
    if (card != nil) {
        return [self initWithContext:context card:card];
    }
    
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithData:data];
    if (request != nil) {
        return [self initWithContext:context request:request];
    }
    
    return nil;
}

- (BOOL)isPublished {
    return self.card != nil;
}

- (NSData *)encryptData:(NSData *)data error:(NSError **)errorPtr {
    return [self.context.crypto encryptData:data forRecipients:@[self.publicKey] error:errorPtr];
}

- (NSData *)encryptString:(NSString *)string error:(NSError **)errorPtr {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self encryptData:data error:errorPtr];
}

- (BOOL)verifyData:(NSData *)data withSignature:(NSData *)signature error:(NSError **)errorPtr {
    return [self.context.crypto verifyData:data withSignature:signature usingSignerPublicKey:self.publicKey error:errorPtr];
}

- (BOOL)verifyString:(NSString *)string withSignature:(NSData *)signature error:(NSError **)errorPtr {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self verifyData:data withSignature:signature error:errorPtr];
}

- (void)publishWithCompletion:(void (^)(NSError *))callback {
    if (self.isPublished) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"This card is already published" }]);
        return;
    }
    
    switch (self.scope) {
        case VSSCardScopeGlobal: break;
        case VSSCardScopeApplication: {
            if (self.context.credentials == nil) {
                callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To create Application card you need to provide Credentials to VirgilApiContext" }]);
                return;
            }
            NSString *appId = self.context.credentials.appId;
            VSSPrivateKey *appKey = self.context.credentials.appKey;
            NSError *error;
            [self.context.requestSigner authoritySignRequest:self.request forAppId:appId withPrivateKey:appKey error:&error];
            if (error != nil) {
                callback(error);
                return;
            }
                
            break;
        }
    }
    
    [self.context.client createCardWithRequest:self.request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            callback(error);
            return;
        }
        
        self.card = card;
        callback(nil);
    }];
}

- (NSString *)identifier {
    if (self.card != nil)
        return self.card.identifier;
    else
        return self.calculatedIdentifier;
}

- (NSString *)identity {
    if (self.card != nil)
        return self.card.identity;
    else
        return self.request.snapshotModel.identity;
}

- (NSString *)identityType {
    if (self.card != nil)
        return self.card.identityType;
    else
        return self.request.snapshotModel.identityType;
}

- (VSSPublicKey *)publicKey {
    NSData *publicKeyData = self.card != nil ? self.card.publicKeyData : self.request.snapshotModel.publicKeyData;
    
    return [self.context.crypto importPublicKeyFromData:publicKeyData];
}

- (NSDictionary<NSString *, NSString *> *)customFields {
    if (self.card != nil)
        return self.card.data;
    else
        return self.request.snapshotModel.data;
}

- (NSDictionary<NSString *, NSString *> *)info {
    if (self.card != nil)
        return self.card.info;
    else
        return self.request.snapshotModel.info;
}

- (VSSCardScope)scope {
    if (self.card != nil)
        return self.card.scope;
    else
        return self.request.snapshotModel.scope;
}

- (instancetype)initWitContext:(VSSVirgilApiContext *)context data:(NSString *)data {
    VSSCard *card = [[VSSCard alloc] initWithData:data];
    if (card != nil)
        return [self initWithContext:context card:card];
    
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithData:data];
    if (request != nil)
        return [self initWithContext:context request:request];
    
    return nil;
}

- (NSString *)exportData {
    if (self.card != nil)
        return [self.card exportData];
    else
        return [self.request exportData];
}

@end
