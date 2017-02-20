//
//  VSSTestsConst.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/24/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)

#import "VSSTestsConst.h"

@implementation VSSTestsConst

- (NSString *)applicationToken {
    return @"AT.20a4afadaed1a064c0d15bec087289fb7d7300f9851a5c2dc4144ba322257384";
}

- (NSString *)applicationPrivateKeyBase64 {
    return @"MIGhMF0GCSqGSIb3DQEFDTBQMC8GCSqGSIb3DQEFDDAiBBDMThWe8pZspEFuh466dCgBAgIYMzAKBggqhkiG9w0CCjAdBglghkgBZQMEASoEENRkuERpBeuflVUikAvr6EIEQLl47XxKoGWZqzyo8HvYMQum915mYDjDVsHpcrZ1hv0AzS8oti+zpYAG9aRjKfOOX3ebLZunc3zfbOOJwg0bPa0=";
}

- (NSString *)applicationPrivateKeyPassword {
    return @"test";
}

- (NSString *)applicationIdentityType {
    return @"test";
}

- (NSString *)applicationId {
    return @"e20830b806e54433950edd67e83578a5a2dadb1edf60300f180cc22eea7ea519";
}

- (NSString *)mailinatorToken {
    return @"168ef865218147e99192ec8d7fe7e4b5";
}

@end
