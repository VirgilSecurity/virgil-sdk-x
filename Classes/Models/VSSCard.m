//
//  VSSCard.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCard.h"
#import "VSSIdentity.h"
#import "VSSPublicKey.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@interface VSSCard ()

@property (nonatomic, copy, readwrite) NSString * __nonnull Hash;
@property (nonatomic, copy, readwrite) VSSIdentity * __nonnull identity;
@property (nonatomic, copy, readwrite) VSSPublicKey * __nonnull publicKey;

@property (nonatomic, copy, readwrite) NSDictionary * __nullable data;
@property (nonatomic, copy, readwrite) NSString * __nullable authorizedBy;

@end

@implementation VSSCard

#pragma mark - Lifecycle

- (instancetype)initWithIdentity:(VSSIdentity *)identity publicKey:(VSSPublicKey *)publicKey data:(NSDictionary *)data info:(NSDictionary<NSString *,NSString *> *)info {
    self = [super init];
    if (self) {
        _identity = [identity copy];
        _publicKey = [publicKey copy];
        _data = [data copy];
        _info = [info copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.identity != nil) {
        [aCoder encodeObject:self.identity forKey:kVSSModelIdentity];
    }
    if (self.publicKey != nil) {
        [aCoder encodeObject:self.publicKey forKey:kVSSModelPublicKey];
    }
    if (self.Hash != nil) {
        [aCoder encodeObject:self.Hash forKey:kVSSModelHash];
    }
    if (self.data != nil) {
        [aCoder encodeObject:self.data forKey:kVSSModelData];
    }
    if (self.authorizedBy != nil) {
        [aCoder encodeObject:self.authorizedBy forKey:kVSSModelAuthorizedBy];
    }
}

#pragma mark - VSSSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    VSSCard *card = (VSSCard *) [super deserializeFrom:candidate];
    
    NSDictionary *identCandidate = [candidate[kVSSModelIdentity] as:[NSDictionary class]];
    card.identity = [VSSIdentity deserializeFrom:identCandidate];
    
    NSObject *keyObject = candidate[kVSSModelPublicKey];
    if ([keyObject isKindOfClass:[NSString class]]) {
        /// This might happen during GET /virgil-card unsigned request.
        /// In this case "public_key": <base64 encoded string with public key data>.
        NSData *key = [[NSData alloc] initWithBase64EncodedString:[keyObject as:[NSString class]] options:0];
        card.publicKey = [[VSSPublicKey alloc] initWithKey:key];
    }
    else if ([keyObject isKindOfClass:[NSDictionary class]]) {
        /// This is most common case for GET /virgil-card signed request.
        card.publicKey = [VSSPublicKey deserializeFrom:[keyObject as:[NSDictionary class]]];
    }
    
    NSString *hsh = [candidate[kVSSModelHash] as:[NSString class]];
    card.Hash = hsh;
    
    NSDictionary *data = [candidate[kVSSModelData] as:[NSDictionary class]];
    card.data = data;
    
    NSString *auth = [candidate[kVSSModelAuthorizedBy] as:[NSString class]];
    card.authorizedBy = auth;
    
    return card;
}

#pragma mark - VSSCannonicalRepresentable



@end
