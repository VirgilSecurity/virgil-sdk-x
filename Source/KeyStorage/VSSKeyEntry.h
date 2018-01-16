//
//  VSSKeyEntry.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represents key entry for VSSKeyStorage.
 */
@interface VSSKeyEntry : NSObject

/**
 Factory method which allocates and initalizes VSSKeyEntry instance.

 @param name NSString with key entry name
 @param value Key raw value
 @param meta NSDictionary with any meta data
 @return allocated and initialized VSSCreateCardRequest instance
 */
+ (VSSKeyEntry * __nonnull)keyEntryWithName:(NSString * __nonnull)name value:(NSData * __nonnull)value meta:(NSDictionary<NSString *, NSString *> * __nullable)meta;

/**
 Factory method which allocates and initalizes VSSKeyEntry instance.

 @param name NSString with key entry name
 @param value Key raw value
 @return allocated and initialized VSSKeyEntry instance
 */
+ (VSSKeyEntry * __nonnull)keyEntryWithName:(NSString * __nonnull)name value:(NSData * __nonnull)value;

/**
 NSString with key entry name
 */
@property (nonatomic, readonly, copy) NSString * __nonnull name;

/**
 Key raw value
 */
@property (nonatomic, readonly, copy) NSData * __nonnull value;

/**
 NSDictionary with any meta data
 */
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> * __nullable meta;

/**
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
