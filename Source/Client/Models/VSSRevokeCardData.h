//
//  VSSRevokeCardData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSModelCommons.h"

@interface VSSRevokeCardData : VSSBaseModel

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;
@property (nonatomic, readonly) VSSCardRevocationReason revocationReason;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
