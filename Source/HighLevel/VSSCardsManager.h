//
//  VSSCardsManager.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardsManagerProtocol.h"

/**
 Implementation of VSSCardsManager protocol.
 VSSCardsManager should not be created by user and is accessible only using VSSVirgilApi.
 */
@interface VSSCardsManager : NSObject <VSSCardsManager>

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
