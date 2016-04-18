//
//  VSSGrabPrivateKeyRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSGrabPrivateKeyRequest.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@interface VSSGrabPrivateKeyRequest ()

@property (nonatomic, strong, readwrite) NSData * __nullable privateKey;
@property (nonatomic, strong, readwrite) GUID * __nullable cardId;

@end

@implementation VSSGrabPrivateKeyRequest

@synthesize privateKey = _privateKey;
@synthesize cardId = _cardId;

- (instancetype)initWithContext:(VSSRequestContext *)context identity:(NSDictionary *)identity cardId:(GUID *)cardId {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if (identity.count > 0) {
        body[kVSSModelIdentity] = identity;
    }
    if (cardId.length > 0) {
        body[kVSSModelVirgilCardId] = cardId;
    }
    [self setRequestBodyWithObject:body];
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context {
    return [self initWithContext:context identity:@{} cardId:@""];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"private-key/actions/grab";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    NSDictionary *object = [candidate as:[NSDictionary class]];
    NSString *b64 = [object[kVSSModelPrivateKey] as:[NSString class]];
    self.privateKey = [[NSData alloc] initWithBase64EncodedString:b64 options:0];
    self.cardId = [object[kVSSModelVirgilCardId] as:[GUID class]];
    return nil;
}

@end
