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

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSURL *configFileUrl = [bundle URLForResource:@"TestConfig" withExtension:@"plist"];
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfURL:configFileUrl];
        _config = config;
    }
    
    return self;
}

- (NSString *)apiPublicKeyId {
    NSString *appToken = self.config[@"ApiPublicKeyId"];

    return appToken;
}

- (NSString *)apiPrivateKeyBase64 {
    NSString *appPrivateKey = self.config[@"ApiPrivateKey"];
    
    return appPrivateKey;
}

- (NSString *)apiPublicKeyBase64 {
    NSString *appPrivateKeyPassword = self.config[@"ApiPublicKey"];

    return appPrivateKeyPassword;
}

- (NSString *)applicationId {
    NSString *appId = self.config[@"AppId"];
    
    return appId;
}

- (NSURL *)serviceURL {
    NSString *cardsUrl = self.config[@"ServiceURL"];
    
    return [[NSURL alloc] initWithString:cardsUrl];
}

- (NSString *)existentCardId {
    NSString *cardId = self.config[@"CardId"];
    
    return cardId;
}

- (NSString *)existentCardIdentity {
    NSString *cardIdentity = self.config[@"CardIdentity"];
    
    return cardIdentity;
}

@end
