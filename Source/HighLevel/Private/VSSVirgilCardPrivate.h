//
//  VSSVirgilCardPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCard.h"
#import "VSSCard.h"

@interface VSSVirgilCard ()

@property (nonatomic) NSData * __nonnull publicKey;

@property (nonatomic, readonly) VSSCard * __nonnull model;

- (instancetype __nonnull)initWithModel:(VSSCard * __nonnull)model;

@end
