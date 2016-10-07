//
//  VSSRevokeCardDataPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardData.h"
#import "VSSCanonicalSerializable.h"
#import "VSSSerializable.h"

@interface VSSRevokeCardData () <VSSSerializable, VSSCanonicalSerializable>

- (instancetype __nonnull)initWithCardId:(NSString * __nonnull)cardId revocationReason:(VSSCardRevocationReason)reason;

@end
