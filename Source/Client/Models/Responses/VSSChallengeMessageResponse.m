//
//  VSSChallengeMessageResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSChallengeMessageResponse.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSChallengeMessageResponse

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *authGrantId = [candidate[kVSSAModelAuthGrantId] as:[NSString class]];
    if (authGrantId.length == 0)
        return nil;
    
    NSString *encMessageStr = [candidate[kVSSAModelEncryptedMessage] as:[NSString class]];
    if (encMessageStr.length == 0)
        return nil;
    
    NSData *encMessage = [[NSData alloc] initWithBase64EncodedString:encMessageStr options:0];
    if (encMessage.length == 0)
        return nil;
    
    self = [super init];
    
    if (self) {
        _authGrantId = [authGrantId copy];
        _encryptedMessage = encMessage;
    }
    
    return self;
}

@end
