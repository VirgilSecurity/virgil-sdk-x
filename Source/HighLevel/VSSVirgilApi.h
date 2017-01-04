//
//  VSSVirgilApi.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsManager.h"
#import "VSSKeysManager.h"

@interface VSSVirgilApi : NSObject

@property (nonatomic, readonly) VSSCardsManager * __nonnull Cards;
@property (nonatomic, readonly) VSSKeysManager * __nonnull Keys;

@end
