//
//  MailinatorEmailRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"

@class MEmail;

@interface MailinatorEmailRequest : MailinatorRequest

@property (nonatomic, strong, readonly) MEmail * __nullable email;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context provider:(id<MailinatorRequestSettingsProvider> __nullable)provider emailId:(NSString * __nonnull)emailId NS_DESIGNATED_INITIALIZER;

@end
