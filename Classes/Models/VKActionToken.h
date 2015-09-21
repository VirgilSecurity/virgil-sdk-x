//
//  VKActionToken.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFModel.h>
#import <VirgilFrameworkiOS/VFTypes.h>

@interface VKActionToken : VFModel

/// UUID for action token at the Virgil Keys Service
@property (nonatomic, copy, readonly) GUID *tokenId;
/// Array with the user data ids which are need to be confirmed for Virgil Keys Service
@property (nonatomic, copy, readonly) NSArray *userIdList;
/// Array with confirmation tokens/codes for each user id from the userIdList.
@property (nonatomic, copy) NSArray *confirmationCodeList;

@end
