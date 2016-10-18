//
//  VSSFingerprint.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSFingerprint : NSObject

@property (nonatomic, copy, readonly) NSData * __nonnull value;
@property (nonatomic, readonly) NSString * __nonnull hexValue;

- (instancetype __nonnull)init NS_UNAVAILABLE;

- (instancetype __nonnull)initWithValue:(NSData * __nonnull)value NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithHex:(NSString * __nonnull)hex NS_DESIGNATED_INITIALIZER;

@end
