//
//  VSSTestsConst.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/24/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

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
    if (appToken != nil)
        return appToken;
    
    return nil;
}

- (NSString *)apiPrivateKeyBase64 {
    NSString *appPrivateKey = self.config[@"ApiPrivateKey"];
    if (appPrivateKey != nil)
        return appPrivateKey;
    
    return nil;
}

- (NSString *)apiPublicKeyBase64 {
    NSString *appPrivateKeyPassword = self.config[@"ApiPublicKey"];
    if (appPrivateKeyPassword != nil)
        return appPrivateKeyPassword;
    
    return nil;
}

- (NSString *)applicationId {
    NSString *appId = self.config[@"AppId"];
    if (appId != nil)
        return appId;
    
    return nil;
}

- (NSURL *)serviceURL {
    NSString *cardsUrl = self.config[@"ServiceURL"];
    if (cardsUrl != nil)
        return [[NSURL alloc] initWithString:cardsUrl];
    
    return nil;
}

@end
