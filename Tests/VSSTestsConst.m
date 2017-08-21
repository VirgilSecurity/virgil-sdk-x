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
    if (appToken != nil)
        return appToken;
    
    return @STRINGIZE2(APPLICATION_TOKEN);
}

- (NSString *)applicationPrivateKeyBase64 {
    NSString *appPrivateKey = self.config[@"AppPrivateKey"];
    if (appPrivateKey != nil)
        return appPrivateKey;
    
    return @STRINGIZE2(APPLICATION_PRIVATE_KEY_BASE64);
}

- (NSString *)applicationPrivateKeyPassword {
    NSString *appPrivateKeyPassword = self.config[@"AppPrivateKeyPassword"];
    if (appPrivateKeyPassword != nil)
        return appPrivateKeyPassword;
    
    return @STRINGIZE2(APPLICATION_PRIVATE_KEY_PASSWORD);
}

- (NSString *)applicationIdentityType {
    NSString *appIdentityType = self.config[@"AppIdentityType"];
    if (appIdentityType != nil)
        return appIdentityType;
    
    return @STRINGIZE2(APPLICATION_IDENTITY_TYPE);
}

- (NSString *)applicationId {
    NSString *appId = self.config[@"AppId"];
    if (appId != nil)
        return appId;
    
    return @STRINGIZE2(APPLICATION_ID);
}

- (NSString *)mailinatorToken {
    NSString *mailinatorToken = self.config[@"MailinatorToken"];
    if (mailinatorToken != nil)
        return mailinatorToken;
    
    return @STRINGIZE2(MAILINATOR_TOKEN);
}

- (NSURL *)cardsServiceURL {
    NSString *cardsUrl = self.config[@"CardsUrl"];
    if (cardsUrl != nil)
        return [[NSURL alloc] initWithString:cardsUrl];
    
    NSString *str = [@STRINGIZE2(CARDS_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)cardsServiceROURL {
    NSString *cardsRoUrl = self.config[@"CardsRoUrl"];
    if (cardsRoUrl != nil)
        return [[NSURL alloc] initWithString:cardsRoUrl];
    
    NSString *str = [@STRINGIZE2(CARDS_SERVICE_RO_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)identityServiceURL {
    NSString *identityUrl = self.config[@"IdentityUrl"];
    if (identityUrl != nil)
        return [[NSURL alloc] initWithString:identityUrl];
    
    NSString *str = [@STRINGIZE2(IDENTITY_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)registrationAuthorityURL {
    NSString *raUrl = self.config[@"RaUrl"];
    if (raUrl != nil)
        return [[NSURL alloc] initWithString:raUrl];
    
    NSString *str = [@STRINGIZE2(REGISTRATION_AUTHORITY_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)authServiceURL {
    NSString *authUrl = self.config[@"AuthUrl"];
    if (authUrl != nil)
        return [[NSURL alloc] initWithString:authUrl];
    
    NSString *str = [@STRINGIZE2(AUTH_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSString *)authServicePublicKeyBase64 {
    NSString *authPublicKey = self.config[@"AuthPublicKey"];
    if (authPublicKey != nil)
        return authPublicKey;
    
    return @STRINGIZE2(AUTH_SERVICE_PUBLIC_KEY_BASE64);
}

@end
