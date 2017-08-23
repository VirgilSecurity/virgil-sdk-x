//
//  VSSKeyAttrs.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 8/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSKeyAttrs : NSObject

@property (nonatomic, readonly) NSString * __nonnull name;
@property (nonatomic, readonly) NSDate * __nonnull creationDate;

/**
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
