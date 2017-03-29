//
//  VSSApplicationIdentity.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/27/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilIdentityPrivate.h"
#import "VSSApplicationIdentity.h"

@implementation VSSApplicationIdentity
    
- (BOOL)isConfimed {
    return YES;
}
    
- (VSSCreateCardRequest *)generateRequestWithPublicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data device:(NSString *)device deviceName:(NSString *)deviceName {
    return nil;
}

@end
