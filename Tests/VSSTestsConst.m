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

- (NSString *)applicationToken {
    NSString *appToken = self.config[@"AppToken"];
    
    return appToken;
}

- (NSString *)applicationPrivateKeyBase64 {
    NSString *appPrivateKey = self.config[@"AppPrivateKey"];
    
    return appPrivateKey;
}

- (NSString *)applicationPrivateKeyPassword {
    NSString *appPrivateKeyPassword = self.config[@"AppPrivateKeyPassword"];
    
    return appPrivateKeyPassword;
}

- (NSString *)applicationIdentityType {
    NSString *appIdentityType = self.config[@"AppIdentityType"];
    
    return appIdentityType;
}

- (NSString *)applicationId {
    NSString *appId = self.config[@"AppId"];
    
    return appId;
}

- (NSString *)mailinatorToken {
    NSString *mailinatorToken = self.config[@"MailinatorToken"];
    
    return mailinatorToken;
}

- (NSURL *)cardsServiceURL {
    NSString *cardsUrl = self.config[@"CardsUrl"];
    
    return [[NSURL alloc] initWithString:cardsUrl];
}

- (NSURL *)cardsServiceROURL {
    NSString *cardsRoUrl = self.config[@"CardsRoUrl"];
    
    return [[NSURL alloc] initWithString:cardsRoUrl];
}

- (NSURL *)identityServiceURL {
    NSString *identityUrl = self.config[@"IdentityUrl"];
    
    return [[NSURL alloc] initWithString:identityUrl];
}

- (NSURL *)registrationAuthorityURL {
    NSString *raUrl = self.config[@"RaUrl"];
    
    return [[NSURL alloc] initWithString:raUrl];
}

- (NSURL *)authServiceURL {
    NSString *authUrl = self.config[@"AuthUrl"];
    
    return [[NSURL alloc] initWithString:authUrl];
}

- (NSString *)authServicePublicKeyBase64 {
    NSString *authPublicKey = self.config[@"AuthPublicKey"];
    
    return authPublicKey;
}

@end
