//
//  VSSUserIdentity.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/27/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilIdentityPrivate.h"
#import "VSSUserIdentity.h"
#import "VSSCreateUserCardRequest.h"

@implementation VSSUserIdentity

- (BOOL)isConfimed {
    return YES;
}
    
- (VSSCreateCardRequest *)generateRequestWithPublicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data device:(NSString *)device deviceName:(NSString *)deviceName {
    return [VSSCreateUserCardRequest createUserCardRequestWithIdentity:self.value identityType:self.type publicKeyData:publicKeyData data:data device:device deviceName:deviceName];
}

@end
