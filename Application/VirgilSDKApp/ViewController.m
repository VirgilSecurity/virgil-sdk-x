//
//  ViewController.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "ViewController.h"

#import "VSSModelTypes.h"
#import "VSSIdentityInfo.h"
#import "VSSPrivateKey.h"
#import "VSSPBKDF+Base64.h"
#import "VSSValidationTokenGenerator.h"

@import VirgilFoundation;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", [[[VSSVirgilVersion alloc] init] versionString]);
    
    NSString *password = @"secret";
    VSSKeyPair *pair = [[VSSKeyPair alloc] initWithPassword:password];
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:pair.privateKey password:password];
    
    NSString *email = @"app-user@app.com";
    
    VSSPBKDF *pbkdf = [[VSSPBKDF alloc] initWithSalt:nil iterations:0];
    NSError *error = nil;
    NSString *obfuscated = [pbkdf base64KeyFromPassword:email size:64 error:&error];
    if (error != nil) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }
    
    VSSIdentityInfo *identity = [[VSSIdentityInfo alloc] initWithType:VSSIdentityTypeCustom value:obfuscated validationToken:nil];
    [VSSValidationTokenGenerator setValidationTokenForIdentityInfo:identity privateKey:privateKey error:&error];
    if (error != nil) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"IDENTITY TYPE: %@", [VSSIdentityTypeHelper toString:identity.type]);
    NSLog(@"IDENTITY VALUE: %@", identity.value);
    NSLog(@"IDENTITY TOKEN: %@", identity.validationToken);
}

@end