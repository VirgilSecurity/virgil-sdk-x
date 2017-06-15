//
//  VSSAuthAckRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthAckRequest.h"
#import "VSSModelKeysPrivate.h"

@implementation VSSAuthAckRequest

- (instancetype)initWithEncryptedMesasge:(NSData *)encryptedMessage {
    self = [super init];
    if (self) {
        _encryptedMessage = [encryptedMessage copy];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSAModelEncryptedMessage] = [self.encryptedMessage base64EncodedStringWithOptions:0];
    
    return dict;
}

@end
