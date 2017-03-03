//
//  VSSCardsManagerPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardsManager.h"
#import "VSSVirgilApiContext.h"

@interface VSSCardsManager ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context NS_DESIGNATED_INITIALIZER;

@end
