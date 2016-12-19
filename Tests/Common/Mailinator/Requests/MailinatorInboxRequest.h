//
//  MailinatorInboxRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"
#import "VSSHTTPRequestContext.h"
#import "MEmailMetadata.h"

@interface MailinatorInboxRequest : MailinatorRequest

@property (nonatomic, strong, readonly) NSArray<MEmailMetadata *> * __nullable metadataList;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context token:(NSString * __nonnull)token to:(NSString * __nonnull)to NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext * __nonnull)context token:(NSString * __nonnull)token NS_UNAVAILABLE;

@end
