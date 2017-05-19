//
//  VSSVirgilApi.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilApi.h"
#import "VSSVirgilCardPrivate.h"
#import "VSSCardsManagerPrivate.h"
#import "VSSKeysManagerPrivate.h"
#import "VSSIdentitiesManagerPrivate.h"

NSString * const kVSSVirgilApiErrorDomain = @"VSSVirgilApiErrorDomain";

@interface VSSVirgilApi ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;

@end

@implementation VSSVirgilApi

@synthesize Identities = _Identities;
@synthesize Cards = _Cards;
@synthesize Keys = _Keys;

- (instancetype)init {
    return [self initWithToken:nil];
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _Identities = [[VSSIdentitiesManager alloc] initWithContext:context];
        _Cards = [[VSSCardsManager alloc] initWithContext:context];
        _Keys = [[VSSKeysManager alloc] initWithContext:context];
    }
    
    return self;
}

- (instancetype)initWithToken:(NSString *)token {
    VSSVirgilApiContext *context = [[VSSVirgilApiContext alloc] initWithToken:token];
    return [self initWithContext:context];
}

- (NSData *)encryptData:(NSData *)data for:(NSArray<VSSVirgilCard *> *)cards error:(NSError **)errorPtr {
    NSMutableArray *publicKeys = [[NSMutableArray alloc] initWithCapacity:cards.count];
    for (VSSVirgilCard *card in cards) {
        [publicKeys addObject:card.publicKey];
    }
    
    return [self.context.crypto encryptData:data forRecipients:publicKeys error:errorPtr];
}

- (NSData *)encryptString:(NSString *)string for:(NSArray<VSSVirgilCard *> *)cards error:(NSError **)errorPtr {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self encryptData:data for:cards error:errorPtr];
}

@end
