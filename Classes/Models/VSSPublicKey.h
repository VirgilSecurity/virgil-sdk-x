//
//  VSSPublicKey.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSBaseModel.h"

@class VSSCard;

@interface VSSPublicKey : VSSBaseModel

/// Actual public key data.
@property (nonatomic, copy, readonly) NSData * __nonnull key;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate * __nullable)createdAt key:(NSData * __nonnull)key NS_DESIGNATED_INITIALIZER;
@end
