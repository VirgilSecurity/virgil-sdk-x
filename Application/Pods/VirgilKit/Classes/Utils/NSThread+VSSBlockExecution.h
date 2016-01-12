//
//  NSThread+VFBlockExecution.h
//  VirgilKit
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (VSSBlockExecution)

- (void)performBlockAsync:(void(^ __nullable)(void))block;
- (void)performBlockSync:(void(^ __nullable)(void))block;

@end
