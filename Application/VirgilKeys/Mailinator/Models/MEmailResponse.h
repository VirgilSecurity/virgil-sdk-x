//
//  MEmailResponse.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFModel.h"

@class MEmail;

@interface MEmailResponse : VFModel

@property (nonatomic, strong, readonly) NSNumber *apiInboxFetchesLeft;
@property (nonatomic, strong, readonly) NSNumber *apiEmailFetchesLeft;
@property (nonatomic, strong, readonly) MEmail *email;
@property (nonatomic, strong, readonly) NSNumber *forwardsLeft;

- (instancetype)initWithInboxFetchesLeft:(NSNumber *)inboxFetchesLeft emailFetchesLeft:(NSNumber *)emailFetchesLeft email:(MEmail *)email forwardsLeft:(NSNumber *)forwardsLeft NS_DESIGNATED_INITIALIZER;

@end
