//
//  VSSCardResponsePrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardResponse.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"
#import "VSSCard.h"

@interface VSSCardResponse () <VSSSerializable, VSSDeserializable>

- (VSSCard * __nonnull)buildCard;

@end
