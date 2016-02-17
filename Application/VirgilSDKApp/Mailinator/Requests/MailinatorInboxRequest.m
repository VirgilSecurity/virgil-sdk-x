//
//  MailinatorInboxRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorInboxRequest.h"
#import "MailinatorRequestSettingsProvider.h"

#import "MEmailMetadata.h"

#import "NSObject+VSSUtils.h"

static NSString *const kMRMessages = @"messages";

@interface MailinatorInboxRequest ()

@property (nonatomic, strong, readwrite) NSArray * __nullable metadataList;
@property (nonatomic, strong) NSString * __nonnull to;

@end

@implementation MailinatorInboxRequest

@synthesize metadataList = _metadataList;
@synthesize to = _to;

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context provider:(id<MailinatorRequestSettingsProvider>)provider to:(NSString *)to {
    self = [super initWithContext:context provider:provider];
    if (self == nil) {
        return nil;
    }
    
    _to = to;
    
    [self setRequestMethod:GET];
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context provider:(id<MailinatorRequestSettingsProvider>)provider {
    return [self initWithContext:context provider:provider to:@""];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    NSString *token = [self.provider mailinatorToken];
    if (token == nil) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"inbox?to=%@&token=%@", self.to, token];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    NSDictionary *messages = [candidate as:[NSDictionary class]];
    NSArray *messagesList = [messages[kMRMessages] as:[NSArray class]];
    
    NSMutableArray *metadataList = [[NSMutableArray alloc] initWithCapacity:[messagesList count]];
    for (NSDictionary *message in messagesList) {
        MEmailMetadata *metadata = [MEmailMetadata deserializeFrom:message];
        if (metadata != nil) {
            [metadataList addObject:metadata];
        }
    }
    
    if (metadataList.count == 0) {
        metadataList = nil;
    }
    
    self.metadataList = metadataList;
    return nil;
}

@end
