//
//  VSSCreateCardRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardRequest.h"
#import "VSSModelCommons.h"
#import "VSSPublicKey.h"
#import "VSSCard.h"
#import "NSObject+VSSUtils.h"

@interface VSSCreateCardRequest ()

@property (nonatomic, strong, readwrite) VSSCard * __nullable card;

@end

@implementation VSSCreateCardRequest

@synthesize card = _card;

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context publicKeyId:(GUID *)pkId identity:(NSDictionary *)identity data:(NSDictionary *)data signs:(NSArray <NSDictionary *>*)signs {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if (pkId.length > 0) {
        body[kVSSModelPublicKeyId] = pkId;
    }
    if (identity.count > 0) {
        body[kVSSModelIdentity] = identity;
    }
    if (data.count > 0) {
        body[kVSSModelData] = data;
    }
    if (signs.count > 0) {
        body[kVSSModelSigns] = signs;
    }
    [self setRequestBodyWithObject:body];
    
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context publicKey:(NSData *)publicKey identity:(NSDictionary *)identity data:(NSDictionary *)data signs:(NSArray <NSDictionary *>*)signs {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if (publicKey.length > 0) {
        NSString *base64 = [publicKey base64EncodedStringWithOptions:0];
        if (base64.length > 0) {
            body[kVSSModelPublicKey] = base64;
        }
    }
    if (identity.count > 0) {
        body[kVSSModelIdentity] = identity;
    }
    if (data.count > 0) {
        body[kVSSModelData] = data;
    }
    if (signs.count > 0) {
        body[kVSSModelSigns] = signs;
    }
    [self setRequestBodyWithObject:body];
    
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context {
    return [self initWithContext:context publicKey:[[NSData alloc] init] identity:@{} data:nil signs:@[]];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"virgil-card";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    /// Deserialize actual card
    self.card = [VSSCard deserializeFrom:[candidate as:[NSDictionary class]]];
    return nil;
}


@end
