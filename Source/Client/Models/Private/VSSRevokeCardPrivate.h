//
//  VSSRevokeCardPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCard.h"

@interface VSSRevokeCard ()

- (instancetype __nonnull)initWithRevokeCardData:(VSSRevokeCardData * __nonnull)data;

- (instancetype __nonnull)initWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

@end
