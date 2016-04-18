//
//  IPMConstants.m
//  IPMExample-objc
//
//  Created by Pavel Gorb on 4/18/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

#import "IPMConstants.h"

const double kTimerInterval = 3.0;

NSString * _Nonnull const kMessageId = @"id";
NSString * _Nonnull const kMessageCreatedAt = @"created_at";
NSString * _Nonnull const kMessageSender = @"sender_identifier";
NSString * _Nonnull const kMessageContent = @"message";
NSString * _Nonnull const kSenderIdentifier = @"identifier";
NSString * _Nonnull const kIdentityToken = @"identity_token";

NSString * _Nonnull const kBaseURL = @"http://198.211.127.242:4000";
NSString * _Nonnull const kIdentityTokenHeader = @"X-IDENTITY-TOKEN";
NSString * _Nonnull const kAppToken = @"eyJpZCI6IjdiOWY1NDlmLTdkNWMtNGI5ZS1hYzc2LWU3MzFhYTgzM2VlNiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiIyYWM4OWZjMC0yNTgxLTQ3ZjMtYmUzMS0wZTE3M2VjMzE3MzYiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MFkwDQYJYIZIAWUDBAICBQAESDBGAiEA9QjxV3a5HEMpz0rTWixTPxco/qnZ5NqLqdd5e6yvKlECIQC2nhRsu5QAzzc4PqYGyStL0kjEHbW25K2DZZ9gyq8s5A==";