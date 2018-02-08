//
//  VSSKeyAttrs.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 8/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class that represents key attributes.
 */
NS_SWIFT_NAME(KeyAttrs)
@interface VSSKeyAttrs : NSObject

/**
 Key's name.
 */
@property (nonatomic, readonly) NSString * __nonnull name;

/**
 Creation date of the key.
 */
@property (nonatomic, readonly) NSDate * __nonnull creationDate;

/**
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
