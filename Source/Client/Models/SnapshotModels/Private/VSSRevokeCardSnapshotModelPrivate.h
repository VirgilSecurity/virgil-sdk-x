//
//  VSSRevokeCardSnapshotModelPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardSnapshotModel.h"
#import "VSSCanonicalSerializable.h"
#import "VSSCanonicalDeserializable.h"
#import "VSSDeserializable.h"
#import "VSSSerializable.h"

@interface VSSRevokeCardSnapshotModel () <VSSSerializable, VSSDeserializable, VSSCanonicalSerializable, VSSCanonicalDeserializable>

- (instancetype __nonnull)initWithCardId:(NSString * __nonnull)cardId revocationReason:(VSSCardRevocationReason)reason;

@end
