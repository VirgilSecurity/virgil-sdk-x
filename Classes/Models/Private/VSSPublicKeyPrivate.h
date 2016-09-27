//
//  VSSPublicKeyPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"
#import "VSSStringRepresentable.h"

@interface VSSPublicKey () <VSSStringRepresentable, NSCoding, NSCopying>

@property (nonatomic, copy, readonly) NSData * __nonnull key;

- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key NS_DESIGNATED_INITIALIZER;

@end
