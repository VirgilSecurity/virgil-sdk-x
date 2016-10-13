//
//  VSSServiceConfig.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSServiceConfig.h"

@implementation VSSServiceConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _cardsServiceURL = [[NSURL alloc] initWithString:@"https://cards.virgilsecurity.com/v4/"];;
        _cardsServiceROURL = [[NSURL alloc] initWithString:@"https://cards-ro.virgilsecurity.com/v4/"];
    }
    return self;
}

+ (VSSServiceConfig *)serviceConfigWithDefaultValues {
    return [[self alloc] init];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    VSSServiceConfig *copy = [VSSServiceConfig serviceConfigWithDefaultValues];
    copy.cardsServiceURL = self.cardsServiceURL;
    copy.cardsServiceROURL = self.cardsServiceROURL;
    copy.cardValidator = self.cardValidator;
    
    return copy;
}

@end
