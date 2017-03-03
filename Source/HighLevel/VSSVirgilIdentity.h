//
//  VSSVirgilIdentity.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"

@interface VSSVirgilIdentity : NSObject

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString * __nonnull value;
@property (nonatomic, readonly) NSString * __nonnull type;
@property (nonatomic, readonly) BOOL isConfimed;

@end
