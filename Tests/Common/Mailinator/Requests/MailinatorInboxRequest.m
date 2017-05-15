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

@property (nonatomic, strong, readwrite) NSArray<MEmailMetadata *> * __nullable metadataList;
@property (nonatomic, strong) NSString * __nonnull to;

@end

@implementation MailinatorInboxRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context token:(NSString * __nonnull)token to:(NSString *)to {
    self = [super initWithContext:context token:token];
    if (self == nil) {
        return nil;
    }
    
    _to = to;
    
    [self setRequestMethod:GET];
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    NSString *token = self.token;
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
    
    NSDictionary *messages = [candidate vss_as:[NSDictionary class]];
    NSArray *messagesList = [messages[kMRMessages] vss_as:[NSArray class]];
    
    NSMutableArray<MEmailMetadata *> *metadataList = [[NSMutableArray alloc] initWithCapacity:[messagesList count]];
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
