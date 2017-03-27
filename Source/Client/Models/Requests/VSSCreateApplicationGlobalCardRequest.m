//
//  VSSCreateApplicationGlobalCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/27/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCreateApplicationGlobalCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"

@implementation VSSCreateApplicationGlobalCardRequest
    
+ (instancetype)createApplicationCardRequestWithIdentity:(NSString *)identity publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:@"application" scope:VSSCardScopeApplication publicKeyData:publicKeyData data:data info:nil];
    return [[VSSCreateApplicationGlobalCardRequest alloc] initWithSnapshotModel:model];
}
    
@end
