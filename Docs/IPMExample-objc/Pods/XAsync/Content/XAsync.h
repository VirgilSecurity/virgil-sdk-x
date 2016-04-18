//
//  Async.h
//
//  Created by Pavlo Gorb on 4/6/16.
//

#import <Foundation/Foundation.h>

typedef void (^XAsyncAction)(void);
typedef id _Nullable (^XAsyncActionResult)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XAsync : NSObject

+ (void)await:(XAsyncAction)action;
+ (id _Nullable)awaitResult:(XAsyncActionResult)action;

@end

NS_ASSUME_NONNULL_END
