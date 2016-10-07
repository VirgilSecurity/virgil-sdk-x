//
//  VSSCardData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"
#import "VSSBaseModel.h"

@interface VSSCardData : VSSBaseModel

@property (nonatomic, copy, readonly) NSString * __nonnull identity;
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;
@property (nonatomic, copy, readonly) NSData * __nonnull publicKey;
@property (nonatomic, copy, readonly) NSDictionary * __nonnull data;
@property (nonatomic, readonly) VSSCardScope scope;
@property (nonatomic, copy, readonly) NSDictionary * __nonnull info;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
