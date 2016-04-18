//
//  VSSKeychainValue.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 12/18/15.
//  Copyright © 2015 VirgilSecurity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * __nonnull const kVSSServiceName;

@interface VSSKeychainValue : NSObject

- (instancetype __nonnull)initWithId:(NSString * __nonnull)idfr accessGroup:(NSString * __nullable)accessGroup;

- (void)reset;
- (void)setObject:(NSObject<NSCoding> * __nullable)candidate forKey:(NSObject<NSCopying> * __nonnull)aKey;
- (NSObject * __nullable)objectForKey:(NSObject <NSCopying>* __nonnull) aKey;

@end
