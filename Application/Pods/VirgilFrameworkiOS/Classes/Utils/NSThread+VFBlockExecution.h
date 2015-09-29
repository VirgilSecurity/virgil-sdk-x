//
//  NSThread+VFBlockExecution.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (VFBlockExecution)

- (void)performBlockAsync:(void(^)(void))block;
- (void)performBlockSync:(void(^)(void))block;

@end
