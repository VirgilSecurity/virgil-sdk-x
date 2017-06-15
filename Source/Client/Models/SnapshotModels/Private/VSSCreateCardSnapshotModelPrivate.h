//
//  VSSCreateCardSnapshotModelPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardSnapshotModel.h"
#import "VSSCanonicalSerializable.h"
#import "VSSCanonicalDeserializable.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSCreateCardSnapshotModel () <VSSSerializable, VSSDeserializable, VSSCanonicalSerializable, VSSCanonicalDeserializable>

@end
