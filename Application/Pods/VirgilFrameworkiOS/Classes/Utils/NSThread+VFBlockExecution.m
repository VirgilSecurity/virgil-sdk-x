//
//  NSThread+VFBlockExecution.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "NSThread+VFBlockExecution.h"

@interface NSThread (VFBlockExecutionPrivate)

- (void)__performBlock:(void(^)(void))block;

@end

@implementation NSThread (BlockExecutionPrivate)

- (void)__performBlock:(void(^)(void))block {
    if (block != nil) {
        block();
    }
}

@end

@implementation NSThread (VFBlockExecution)

- (void)performBlockAsync:(void(^)(void))block {
    if ([NSThread currentThread] == self) {
        block();
        return;
    }
    
    [self performSelector:@selector(__performBlock:) onThread:self withObject:block waitUntilDone:NO];
}

- (void)performBlockSync:(void(^)(void))block {
    if ([NSThread currentThread] == self) {
        block();
        return;
    }
    
    [self performSelector:@selector(__performBlock:) onThread:self withObject:block waitUntilDone:YES];
}

@end
