//
//  MailinatorEmailRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"
#import "VSSHTTPRequestContext.h"

@class MEmail;

@interface MailinatorEmailRequest : MailinatorRequest

@property (nonatomic, strong, readonly) MEmail * __nullable email;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context token:(NSString * __nonnull)token emailId:(NSString * __nonnull)emailId NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context token:(NSString * __nonnull)token NS_UNAVAILABLE;

@end
