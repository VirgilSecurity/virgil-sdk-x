//
//  VSSPrivateKey.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"

@interface VSSPrivateKey : VSSModel

@property (nonatomic, copy, readonly) NSData * __nonnull key;

@property (nonatomic, copy, readonly) NSString * __nullable password;

- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key password:(NSString * __nullable)password NS_DESIGNATED_INITIALIZER;

@end
