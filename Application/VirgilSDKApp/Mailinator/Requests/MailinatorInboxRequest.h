//
//  MailinatorInboxRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"

@interface MailinatorInboxRequest : MailinatorRequest

@property (nonatomic, strong, readonly) NSArray * __nullable metadataList;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context provider:(id<MailinatorRequestSettingsProvider> __nullable)provider to:(NSString * __nonnull)to NS_DESIGNATED_INITIALIZER;

@end
