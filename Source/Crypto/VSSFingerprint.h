//
//  VSSFingerprint.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class representing fingerprint of some data.
 See VSSCrypto protocol.
 */
@interface VSSFingerprint : NSObject

/**
 NSData with raw value of VSSFingerprint
 */
@property (nonatomic, copy, readonly) NSData * __nonnull value;

/**
 NSString with hex value of VSSFingerprint
 */
@property (nonatomic, readonly) NSString * __nonnull hexValue;

/**
 Designated initializer. Initializes VSSFingerprint instance with raw value.

 @param value NSData with VSSFingerprint value

 @return initialized VSSFingerprint instance
 */
- (instancetype __nonnull)initWithValue:(NSData * __nonnull)value NS_DESIGNATED_INITIALIZER;

/**
 Designated initializer. Initializes VSSFingerprint instance with hex value.

 @param hex NSString with VSSFingerprint hex value

 @return initialized VSSFingerprint instance
 */
- (instancetype __nonnull)initWithHex:(NSString * __nonnull)hex NS_DESIGNATED_INITIALIZER;

/**
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
