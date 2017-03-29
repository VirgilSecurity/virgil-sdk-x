//
//  VSSServiceConfig.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSServiceConfig.h"

@implementation VSSServiceConfig

- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        _token = [token copy];
        _cardsServiceURL = [[NSURL alloc] initWithString:@"https://cards.virgilsecurity.com/v4/"];
        _cardsServiceROURL = [[NSURL alloc] initWithString:@"https://cards-ro.virgilsecurity.com/v4/"];
        _identityServiceURL = [[NSURL alloc] initWithString:@"https://identity.virgilsecurity.com/v1/"];
        _registrationAuthorityURL = [[NSURL alloc] initWithString:@"https://ra.virgilsecurity.com/v1/"];
        _authServiceURL = [[NSURL alloc] initWithString:@"https://auth.virgilsecurity.com/v4/"];
    }
    return self;
}

+ (VSSServiceConfig *)serviceConfigWithToken:(NSString *)token {
    return [[self alloc] initWithToken:token];
}

+ (VSSServiceConfig *)defaultServiceConfig {
    return [[self alloc] initWithToken:nil];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    VSSServiceConfig *copy = [VSSServiceConfig serviceConfigWithToken:self.token];
    copy.cardsServiceURL = self.cardsServiceURL;
    copy.cardsServiceROURL = self.cardsServiceROURL;
    copy.cardValidator = self.cardValidator;
    copy.identityServiceURL = self.identityServiceURL;
    copy.registrationAuthorityURL = self.registrationAuthorityURL;
    copy.authServiceURL = self.authServiceURL;
    
    return copy;
}

@end
