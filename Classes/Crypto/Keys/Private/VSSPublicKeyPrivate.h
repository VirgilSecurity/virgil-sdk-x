//
//  VSSPublicKeyPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"

@interface VSSPublicKey () <NSCoding, NSCopying>

@property (nonatomic, copy, readonly) NSData * __nonnull key;
@property (nonatomic, copy, readonly) NSData * __nonnull identifier;

- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key identifier:(NSData * __nonnull)identifier NS_DESIGNATED_INITIALIZER;

@end
