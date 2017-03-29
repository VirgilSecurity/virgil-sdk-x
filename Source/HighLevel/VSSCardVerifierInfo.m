//
//  VSSCardVerifierInfo.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardVerifierInfo.h"

@implementation VSSCardVerifierInfo

- (instancetype)initWithCardId:(NSString *)cardId publicKeyData:(NSData *)publicKeyData {
    self = [super init];
    if (self) {
        _cardId = [cardId copy];
        _publicKeyData = [publicKeyData copy];
    }
    
    return self;
}

@end
