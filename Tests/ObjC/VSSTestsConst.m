//
//  VSSTestsConst.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/24/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSTestsConst.h"

@implementation VSSTestsConst

- (NSString *)applicationToken {
    return [NSProcessInfo processInfo].environment[@"kApplicationToken"];
}

- (NSString *)applicationPublicKeyBase64 {
    return [NSProcessInfo processInfo].environment[@"kApplicationPublicKeyBase64"];
}

- (NSString *)applicationPrivateKeyBase64 {
    return [NSProcessInfo processInfo].environment[@"kApplicationPrivateKeyBase64"];
}

- (NSString *)applicationPrivateKeyPassword {
    return [NSProcessInfo processInfo].environment[@"kApplicationPrivateKeyPassword"];
}

- (NSString *)applicationIdentityType {
    return [NSProcessInfo processInfo].environment[@"kApplicationIdentityType"];
}

- (NSString *)applicationId {
    return [NSProcessInfo processInfo].environment[@"kApplicationId"];
}

@end
