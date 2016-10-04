//
//  VSSCreateCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseRequest.h"
#import "VSSModelCommons.h"
#import "VSSCardModel.h"

@interface VSSCreateCardRequest : VSSCardsBaseRequest

@property (nonatomic) VSSCardModel * __nullable cardModel;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context cardModel:(VSSCardModel * __nonnull)model NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context NS_UNAVAILABLE;

@end
