//
//  VSSConfirmIdentityRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSConfirmIdentityRequest.h"
#import "VSSModelKeys.h"

@implementation VSSConfirmIdentityRequest

- (instancetype)initWithConfirmationCode:(NSString *)confirmationCode actionId:(NSString *)actionId tokenTTL:(NSInteger)tokenTTL tokenCTL:(NSInteger)tokenCTL {
    self = [super init];
    if (self) {
        _confirmationCode = [confirmationCode copy];
        _actionId = [actionId copy];
        _tokenTTL = tokenTTL;
        _tokenCTL = tokenCTL;
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSIModelConfirmationCode] = [self.confirmationCode copy];
    dict[kVSSIModelActionId] = [self.actionId copy];
    
    NSMutableDictionary *tokenDict = [[NSMutableDictionary alloc] init];
    tokenDict[kVSSIModelCTL] = [[NSNumber alloc] initWithInteger:self.tokenCTL];
    tokenDict[kVSSIModelTTL] = [[NSNumber alloc] initWithInteger:self.tokenTTL];
    
    dict[kVSSIModelToken] = tokenDict;
    
    return dict;
}

@end
