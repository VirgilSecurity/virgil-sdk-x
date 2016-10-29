//
//  VSSSnapshotModelPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSnapshotModel.h"
#import "VSSCanonicalSerializable.h"
#import "VSSCanonicalDeserializable.h"

@interface VSSSnapshotModel () <VSSCanonicalSerializable, VSSCanonicalDeserializable>

@end
