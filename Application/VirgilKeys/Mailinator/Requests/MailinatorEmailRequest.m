//
//  MailinatorEmailRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorEmailRequest.h"

#import "MEmail.h"
#import "MEmailResponse.h"
#import "MailinatorRequestSettingsProvider.h"

#import <VirgilKit/NSObject+VSSUtils.h>

@interface MailinatorEmailRequest ()

@property (nonatomic, strong, readwrite) MEmail *email;
@property (nonatomic, strong) NSString* emailId;

@end

@implementation MailinatorEmailRequest

@synthesize email = _email;
@synthesize emailId = _emailId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url provider:(id<MailinatorRequestSettingsProvider>)provider emailId:(NSString *)emailId {
    self = [super initWithBaseURL:url provider:provider];
    if (self == nil) {
        return nil;
    }
    _emailId = emailId;
    
    [self setRequestMethod:GET];
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url provider:(id<MailinatorRequestSettingsProvider>)provider {
    return [self initWithBaseURL:url provider:provider emailId:nil];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    NSString *token = [self.provider mailinatorToken];
    if (token == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"email?id=%@&token=%@", self.emailId, token];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    NSDictionary *emailCandidate = [candidate as:[NSDictionary class]];
    MEmailResponse *response = [MEmailResponse deserializeFrom:emailCandidate];
    self.email = response.email;
    
    return nil;
}

@end
