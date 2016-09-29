//
//  VSSCard.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"
#import "VSSCanonicalRepresentable.h"
#import "VSSSerializable.h"
#import "VSSModelCommons.h"
#import "VSSCardData.h"

@interface VSSCard : VSSBaseModel <VSSCanonicalRepresentable, VSSSerializable>

@property (nonatomic, copy, readonly) VSSCardData * __nonnull cardData;
@property (nonatomic, copy, readonly) VSSCardMetaData * __nonnull metaData;

- (instancetype __nonnull)initWithCardData:(VSSCardData * __nonnull)cardData metaData:(VSSCardMetaData * __nonnull)metaData NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
