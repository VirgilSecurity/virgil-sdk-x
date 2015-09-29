//
//  MailinatorRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"
#import "MailinatorRequestSettingsProvider.h"

#import <VirgilFrameworkiOS/VFError.h>
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

@interface MailinatorRequest ()

@property (nonatomic, weak, readwrite) id<MailinatorRequestSettingsProvider> provider;

@end

@implementation MailinatorRequest

@synthesize provider = _provider;

- (instancetype)initWithBaseURL:(NSString *)url provider:(id<MailinatorRequestSettingsProvider>)provider {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _provider = provider;
    return self;
}

- (NSError *)handleError:(NSObject *)candidate {
    NSError *error = [super handleError:candidate];
    if (error != nil) {
        return error;
    }
    
    VFError *vfError = [VFError deserializeFrom:[candidate as:[NSDictionary class]]];
    return vfError.nsError;
}

@end
