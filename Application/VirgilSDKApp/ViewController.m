//
//  ViewController.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "ViewController.h"

#import "VSSClient.h"

#import "VSSCard.h"
#import "VSSPublicKey.h"
#import "VSSPrivateKey.h"

@import VirgilFoundation;

@interface ViewController ()

@property (nonatomic, strong) VSSClient *client;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", [[[VSSVirgilVersion alloc] init] versionString]);    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end