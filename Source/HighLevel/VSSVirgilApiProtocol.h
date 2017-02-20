//
//  VSSVirgilApiProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardsManagerProtocol.h"
#import "VSSKeysManagerProtocol.h"

@protocol VSSVirgilApi <NSObject>

@property (nonatomic, readonly) id<VSSCardsManager> __nonnull Cards;
@property (nonatomic, readonly) id<VSSKeysManager> __nonnull Keys;

@end
