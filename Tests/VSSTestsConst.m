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

- (NSString *)accessPublicKeyId {
    NSString *appToken = self.config[@"AccessPublicKeyId"];
    if (appToken != nil)
        return appToken;
    
    return @STRINGIZE2(APPLICATION_TOKEN);
}

- (NSString *)accessPrivateKeyBase64 {
    NSString *appPrivateKey = self.config[@"AccessPrivateKey"];
    if (appPrivateKey != nil)
        return appPrivateKey;
    
    return @STRINGIZE2(APPLICATION_PRIVATE_KEY_BASE64);
}

- (NSString *)accessPublicKeyBase64 {
    NSString *appPrivateKeyPassword = self.config[@"AccessPublicKey"];
    if (appPrivateKeyPassword != nil)
        return appPrivateKeyPassword;
    
    return @STRINGIZE2(APPLICATION_PRIVATE_KEY_PASSWORD);
}

- (NSString *)applicationId {
    NSString *appId = self.config[@"AppId"];
    if (appId != nil)
        return appId;
    
    return @STRINGIZE2(APPLICATION_ID);
}

- (NSURL *)serviceURL {
    NSString *cardsUrl = self.config[@"ServiceURL"];
    if (cardsUrl != nil)
        return [[NSURL alloc] initWithString:cardsUrl];
    
    NSString *str = [@STRINGIZE2(CARDS_SERVICE_URL) stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [[NSURL alloc] initWithString:str];
}

@end
