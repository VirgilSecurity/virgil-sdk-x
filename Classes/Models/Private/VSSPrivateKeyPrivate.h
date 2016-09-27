//
//  VSSPrivateKeyPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKey.h"

@interface VSSPrivateKey () <NSCoding, VSSDeserializable, NSCopying>

@property (nonatomic, copy, readonly) NSData * __nonnull key;
@property (nonatomic, copy, readonly) NSString * __nullable password;
@property (nonatomic, copy, readonly) NSData * __nonnull publicKey;

- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key password:(NSString * __nullable)password publicKey:(NSData * __nonnull)publicKey NS_DESIGNATED_INITIALIZER;

@end
