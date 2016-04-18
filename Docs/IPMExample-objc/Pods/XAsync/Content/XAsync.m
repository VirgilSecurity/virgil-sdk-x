//
//  Async.m
//
//  Created by Pavel Gorb on 4/6/16.
//

#import "XAsync.h"

static void __taskPerform(void *info);

NS_ASSUME_NONNULL_BEGIN

@interface XAsync ()

+ (CFRunLoopSourceRef)source;

@end

NS_ASSUME_NONNULL_END

@implementation XAsync

+ (void)await:(XAsyncAction)action {
    if (action == nil) {
        return;
    }
    
    CFRunLoopRef callerRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = [self source];
    
    if (!CFRunLoopContainsSource(callerRunLoop, source, kCFRunLoopCommonModes)) {
        CFRunLoopAddSource(callerRunLoop, source, kCFRunLoopCommonModes);
    }
    
    NSInteger __block done = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        action();
        done = 1;
        CFRunLoopSourceSignal(source);
        CFRunLoopWakeUp(callerRunLoop);
    });
    
    while(!done) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
    }
}

+ (id _Nullable)awaitResult:(XAsyncActionResult)action {
    if (action == nil) {
        return nil;
    }
    
    CFRunLoopRef callerRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = [self source];
    
    if (!CFRunLoopContainsSource(callerRunLoop, source, kCFRunLoopCommonModes)) {
        CFRunLoopAddSource(callerRunLoop, source, kCFRunLoopCommonModes);
    }
    
    id __block result = nil;
    NSInteger __block done = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        result = action();
        done = 1;
        CFRunLoopSourceSignal(source);
        CFRunLoopWakeUp(callerRunLoop);
    });
    
    while(!done) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
    }
    
    return result;
}

+ (CFRunLoopSourceRef)source {
    static CFRunLoopSourceRef __source;
    static dispatch_once_t __sourceToken;
    dispatch_once(&__sourceToken, ^{
        CFRunLoopSourceContext context;
        memset(&context, 0, sizeof(context));
        context.perform = __taskPerform;
        context.info = NULL;
        
        __source = CFRunLoopSourceCreate(NULL, 0, &context);
    });
    return __source;
}

@end

static void __taskPerform(void *info) {
    
}