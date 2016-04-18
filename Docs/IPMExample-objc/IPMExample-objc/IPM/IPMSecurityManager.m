//
//  IPMSecurityManager.m
//  IPMExample-objc
//
//  Created by Pavel Gorb on 4/18/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

#import "IPMSecurityManager.h"
#import "IPMConstants.h"

@import VirgilFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface IPMSecurityManager ()

@property (nonatomic, strong, readwrite) NSString *identity;
@property (nonatomic, strong, readwrite) VSSPrivateKey *privateKey;

@property (nonatomic, strong) NSMutableDictionary *cardCache;
@property (nonatomic, strong) VSSClient *client;

@property (atomic, assign) BOOL clientSetUp;
@property (atomic, strong) NSObject *mutex;

@property (nonatomic, strong) NSString *actionId;
@property (nonatomic, strong) NSString *validationToken;

- (XAsyncActionResult)setup;

@end

NS_ASSUME_NONNULL_END

@implementation IPMSecurityManager

@synthesize cardCache = _cardCache;
@synthesize client = _client;
@synthesize clientSetUp = _clientSetUp;
@synthesize mutex = _mutex;

@synthesize identity = _identity;
@synthesize privateKey = _privateKey;

@synthesize actionId = _actionId;
@synthesize validationToken = _validationToken;

- (instancetype)initWithIdentity:(NSString *)identity {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _identity = identity;
    _privateKey = [[VSSPrivateKey alloc] initWithKey:[NSData data] password:@""];
    _cardCache = [NSMutableDictionary dictionary];

    _client = [[VSSClient alloc] initWithApplicationToken:kAppToken];
    _clientSetUp = NO;
    _mutex = [[NSObject alloc] init];
    _actionId = @"";
    _validationToken = @"";
    return self;
}

- (instancetype)init {
    return [self initWithIdentity:@""];
}

- (void)cacheCardForIdentities:(NSArray *)identities {
    NSError *setupError = [XAsync awaitResult:[self setup]];
    if (setupError != nil) {
        NSLog(@"Client setup error: %@", [setupError localizedDescription]);
        return;
    }
    
    if (identities.count == 0) {
        NSLog(@"No identities to cache.");
        return;
    }
    
    [XAsync await:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSInteger __block itemsCount = [identities count];
        for(NSString *identity in identities) {
            VSSCard * __block candidate = nil;
            @synchronized (self.mutex) {
                candidate = [self.cardCache[identity] as:[VSSCard class]];
            }
            if (candidate != nil) {
                --itemsCount;
                if (itemsCount == 0) {
                    dispatch_semaphore_signal(semaphore);
                    return;
                }
                continue;
            }
            
            [self.client searchCardWithIdentityValue:identity type:VSSIdentityTypeEmail relations:nil unconfirmed:nil completionHandler:^(NSArray<VSSCard *> * _Nullable cards, NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error searching cards: %@", [error localizedDescription]);
                }
                else {
                    if (cards.count > 0) {
                        @synchronized (self.mutex) {
                            self.cardCache[identity] = cards[0];
                        }
                    }
                }
                
                --itemsCount;
                if (itemsCount == 0) {
                    dispatch_semaphore_signal(semaphore);
                    return;
                }
            }];
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

- (BOOL)checkSignature:(NSData *)signature data:(NSData *)data identity:(NSString *)identity {
    [self cacheCardForIdentities:@[identity]];
    
    BOOL __block ok = NO;
    [XAsync await:^{
        VSSCard *sender = nil;
        @synchronized (self.mutex) {
            sender = [self.cardCache[identity] as:[VSSCard class]];
        }
        if (sender == nil) {
            return;
        }
        
        VSSSigner *verifier = [[VSSSigner alloc] init];
        NSError *checkError = nil;
        ok = [verifier verifySignature:signature data:data publicKey:sender.publicKey.key error:&checkError];
    }];
    return ok;
}

- (NSData * _Nullable)encryptData:(NSData *)data identities:(NSArray *)identities {
    [self cacheCardForIdentities:identities];
    
    return [XAsync awaitResult:^ id {
        VSSCryptor *cryptor = [[VSSCryptor alloc] init];
        for (NSString *identity in identities) {
            VSSCard *recipient = nil;
            @synchronized (self.mutex) {
                recipient = [self.cardCache[identity] as:[VSSCard class]];
            }
            if (recipient != nil) {
                [cryptor addKeyRecipient:recipient.Id publicKey:recipient.publicKey.key];
            }
        }
        
        return [cryptor encryptData:data embedContentInfo:@YES error:nil];
    }];
}

- (NSData * _Nullable)decryptData:(NSData *)data {
    [self cacheCardForIdentities:@[self.identity]];
    
    return [XAsync awaitResult:^ id {
        VSSCard *recipient = nil;
        @synchronized (self.mutex) {
            recipient = self.cardCache[self.identity];
        }
        if (recipient == nil) {
            return nil;
        }
        
        VSSCryptor *decryptor = [[VSSCryptor alloc] init];
        return [decryptor decryptData:data recipientId:recipient.Id privateKey:self.privateKey.key keyPassword:self.privateKey.password error:nil];
    }];
}

- (NSData * _Nullable)composeSignatureOnData:(NSData *)data {
    return [XAsync awaitResult:^ id {
        VSSSigner *signer = [[VSSSigner alloc] init];
        return [signer signData:data privateKey:self.privateKey.key keyPassword:self.privateKey.password error:nil];
    }];
}

#pragma mark - Registration/authentication routines

- (XAsyncActionResult)verifyIdentity {
    return ^ id {
        NSError * __block actionError = [XAsync awaitResult:[self setup]];
        if (actionError != nil) {
            return actionError;
        }
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self.client verifyIdentityWithType:VSSIdentityTypeEmail value:self.identity completionHandler:^(GUID * _Nullable actionId, NSError * _Nullable error) {
            if (error != nil) {
                actionError = error;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            self.actionId = actionId;
            actionError = nil;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return actionError;
    };
}

- (XAsyncActionResult)confirmWithCode:(NSString *)code {
    return ^ id {
        NSError * __block actionError = [XAsync awaitResult:[self setup]];
        if (actionError != nil) {
            return actionError;
        }
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self.client confirmIdentityWithActionId:self.actionId code:code ttl:nil ctl:nil completionHandler:^(VSSIdentityType type, NSString * _Nullable value, NSString * _Nullable validationToken, NSError * _Nullable error) {
            if (error != nil) {
                actionError = error;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            self.validationToken = validationToken;
            actionError = nil;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return actionError;
    };
}

- (XAsyncActionResult)signin {
    return ^ id {
        NSError * __block actionError = [XAsync awaitResult:[self setup]];
        if (actionError != nil) {
            return actionError;
        }
        
        [self cacheCardForIdentities:@[self.identity]];
        VSSCard * __block card = nil;
        @synchronized (self.mutex) {
            card = [self.cardCache[self.identity] as:[VSSCard class]];
        }
        if (card == nil) {
            return [NSError errorWithDomain:@"ErrorDomain" code:-5555 userInfo:nil];
        }
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSDictionary *idict = @{ kVSSModelValue: self.identity, kVSSModelType: [VSSIdentity stringFromIdentityType:VSSIdentityTypeEmail], kVSSModelValidationToken: self.validationToken };
        [self.client grabPrivateKeyWithIdentity:idict cardId:card.Id password:nil completionHandler:^(NSData * _Nullable keyData, GUID * _Nullable cardId, NSError * _Nullable error) {
            if (error != nil) {
                actionError = error;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            self.actionId = @"";
            self.validationToken = @"";
            self.privateKey = [[VSSPrivateKey alloc] initWithKey:keyData password:nil];
            actionError = nil;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return actionError;
    };
}

- (XAsyncActionResult)signup {
    return ^ id {
        NSError * __block actionError = [XAsync awaitResult:[self setup]];
        if (actionError != nil) {
            return actionError;
        }
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        VSSKeyPair *pair = [[VSSKeyPair alloc] initWithPassword:nil];
        self.privateKey = [[VSSPrivateKey alloc] initWithKey:pair.privateKey password:nil];
        NSDictionary *idict = @{ kVSSModelValue: self.identity, kVSSModelType: [VSSIdentity stringFromIdentityType:VSSIdentityTypeEmail], kVSSModelValidationToken: self.validationToken };
        [self.client createCardWithPublicKey:pair.publicKey identity:idict data:nil signs:nil privateKey:self.privateKey completionHandler:^(VSSCard * _Nullable card, NSError * _Nullable error) {
            if (error != nil || card == nil) {
                actionError = error;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            @synchronized (self.mutex) {
                self.cardCache[self.identity] = card;
            }
            
            [self.client storePrivateKey:self.privateKey cardId:card.Id completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    actionError = error;
                    dispatch_semaphore_signal(semaphore);
                    return;
                }
                
                self.actionId = @"";
                self.validationToken = @"";
                dispatch_semaphore_signal(semaphore);
            }];
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return actionError;
    };
}

#pragma mark - Private class logic

- (XAsyncActionResult)setup {
    return ^ id {
        if (self.clientSetUp) {
            return nil;
        }
        
        NSError * __block actionError = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self.client setupClientWithCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                actionError = error;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            self.clientSetUp = YES;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return actionError;
    };
}

@end
