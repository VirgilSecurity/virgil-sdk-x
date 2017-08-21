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
    if (self.config != nil)
        return self.config[@"AppToken"];
    
    return @STRINGIZE2(APPLICATION_TOKEN);
}

- (NSString *)applicationPrivateKeyBase64 {
    if (self.config != nil)
        return self.config[@"AppPrivateKey"];
    
    return @STRINGIZE2(APPLICATION_PRIVATE_KEY_BASE64);
}

- (NSString *)applicationPrivateKeyPassword {
    if (self.config != nil)
        return self.config[@"AppPrivateKeyPassword"];
    
    return @STRINGIZE2(APPLICATION_PRIVATE_KEY_PASSWORD);
}

- (NSString *)applicationIdentityType {
    if (self.config != nil)
        return self.config[@"AppIdentityType"];
    
    return @STRINGIZE2(APPLICATION_IDENTITY_TYPE);
}

- (NSString *)applicationId {
    if (self.config != nil)
        return self.config[@"AppId"];
    
    return @STRINGIZE2(APPLICATION_ID);
}

- (NSString *)mailinatorToken {
    if (self.config != nil)
        return self.config[@"MailinatorToken"];
    
    return @STRINGIZE2(MAILINATOR_TOKEN);
}

- (NSURL *)cardsServiceURL {
    if (self.config != nil)
        return [[NSURL alloc] initWithString:self.config[@"CardsUrl"]];
    
    NSString *str = [@STRINGIZE2(CARDS_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)cardsServiceROURL {
    if (self.config != nil)
        return [[NSURL alloc] initWithString:self.config[@"CardsRoUrl"]];
    
    NSString *str = [@STRINGIZE2(CARDS_SERVICE_RO_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)identityServiceURL {
    if (self.config != nil)
        return [[NSURL alloc] initWithString:self.config[@"IdentityUrl"]];
    
    NSString *str = [@STRINGIZE2(IDENTITY_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)registrationAuthorityURL {
    if (self.config != nil)
        return [[NSURL alloc] initWithString:self.config[@"RaUrl"]];
    
    NSString *str = [@STRINGIZE2(REGISTRATION_AUTHORITY_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSURL *)authServiceURL {
    if (self.config != nil)
        return [[NSURL alloc] initWithString:self.config[@"AuthUrl"]];
    
    NSString *str = [@STRINGIZE2(AUTH_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

- (NSString *)authServicePublicKeyBase64 {
    if (self.config != nil)
        return self.config[@"AuthPublicKey"];
    
    return @STRINGIZE2(AUTH_SERVICE_PUBLIC_KEY_BASE64);
}

@end
