//
//  VSSCardPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCard.h"
#import "VSSSignedData.h"
#import "VSSSignedDataPrivate.h"

@interface VSSCard () <VSSSerializable, VSSDeserializable>

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot cardData:(VSSCardData * __nonnull)cardData;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot;

- (instancetype __nonnull)initWithCardData:(VSSCardData * __nonnull)cardData;

@end
