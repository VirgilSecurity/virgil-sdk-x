//
//  VSSCardResponsePrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardResponse.h"
#import "VSSSerializable.h"
#import "VSSCard.h"

@interface VSSCardResponse () <VSSSerializable>

- (VSSCard * __nonnull)buildCard;

@end
