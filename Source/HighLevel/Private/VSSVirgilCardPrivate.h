//
//  VSSVirgilCardPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCard.h"
#import "VSSCard.h"
#import "VSSCreateCardRequest.h"
#import "VSSVirgilApiContext.h"

@interface VSSVirgilCard ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;
@property (nonatomic) NSData * __nonnull publicKey;
@property (nonatomic, readonly) VSSCard * __nullable model;
//@property (nonatomic, readonly) VSSCreateCardRequest * __nullable card;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context model:(VSSCard * __nonnull)model NS_DESIGNATED_INITIALIZER;

@end
