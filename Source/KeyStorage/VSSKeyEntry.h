//
//  VSSKeyEntry.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSKeyEntry : NSObject

+ (VSSKeyEntry * __nonnull)keyEntryWithName:(NSString * __nonnull)name value:(NSData * __nonnull)value meta:(NSDictionary<NSString *, NSString *> * __nullable)meta;
+ (VSSKeyEntry * __nonnull)keyEntryWithName:(NSString * __nonnull)name value:(NSData * __nonnull)value;

@property (nonatomic, readonly, copy) NSString * __nonnull name;
@property (nonatomic, readonly, copy) NSData * __nonnull value;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> * __nullable meta;

/**
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
