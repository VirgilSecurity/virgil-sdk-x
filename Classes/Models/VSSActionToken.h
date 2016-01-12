//
//  VSSActionToken.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilKit/VSSModel.h>
#import <VirgilKit/VSSTypes.h>

@interface VSSActionToken : VSSModel

/// UUID for action token at the Virgil Keys Service
@property (nonatomic, copy, readonly) GUID * __nonnull tokenId;
/// Array with the user data ids which are need to be confirmed for Virgil Keys Service
@property (nonatomic, copy, readonly) NSArray * __nonnull userIdList;
/// Array with confirmation tokens/codes for each user id from the userIdList.
@property (nonatomic, copy) NSArray * __nullable confirmationCodeList;

- (instancetype __nonnull)initWithTokenId:(GUID * __nonnull)tokenId userIdList:(NSArray * __nonnull)userIdList confirmationCodeList:(NSArray * __nullable)codeList NS_DESIGNATED_INITIALIZER;

@end
