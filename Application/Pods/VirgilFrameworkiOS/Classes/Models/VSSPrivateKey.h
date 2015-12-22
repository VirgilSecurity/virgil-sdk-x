//
//  VSSPrivateKey.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 10/12/15.
//  Copyright © 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSPrivateKey : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy, readonly) NSData  * __nonnull key;
@property (nonatomic, copy, readonly) NSString  * __nullable password;

- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key password:(NSString * __nullable)password NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key;

@end
