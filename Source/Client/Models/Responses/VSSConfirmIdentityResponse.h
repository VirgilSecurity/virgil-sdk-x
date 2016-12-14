//
//  VSSConfirmIdentityResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSCreateCardSnapshotModel.h"

@interface VSSConfirmIdentityResponse : VSSBaseModel

@property (nonatomic, copy, readonly) NSString * __nonnull identityType;

@property (nonatomic, copy, readonly) NSString * __nonnull identityValue;

@property (nonatomic, copy, readonly) NSString * __nonnull validationToken;

@end
