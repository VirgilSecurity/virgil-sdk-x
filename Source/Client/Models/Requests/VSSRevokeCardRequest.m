//
//  VSSRevokeCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardRequest.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"

@implementation VSSRevokeCardRequest

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSRevokeCardSnapshotModel createFromCanonicalForm:snapshot];
}

@end
