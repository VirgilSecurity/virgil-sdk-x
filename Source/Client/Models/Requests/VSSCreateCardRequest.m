//
//  VSSCreateCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardRequest.h"
#import "VSSCreateCardSnapshotModelPrivate.h"

@implementation VSSCreateCardRequest

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSCreateCardSnapshotModel createFromCanonicalForm:snapshot];
}

@end
