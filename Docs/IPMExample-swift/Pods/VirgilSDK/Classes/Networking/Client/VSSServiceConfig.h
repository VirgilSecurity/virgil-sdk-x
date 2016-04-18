//
//  VSSServiceConfig.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * __nonnull const kVSSServiceIDKeys;
extern NSString * __nonnull const kVSSServiceIDPrivateKeys;
extern NSString * __nonnull const kVSSServiceIDIdentity;

@interface VSSServiceConfig : NSObject

+ (VSSServiceConfig * __nonnull)serviceConfig;

- (NSArray <NSString *>* __nonnull)serviceIDList;
- (NSString * __nonnull)serviceURLForServiceID:(NSString * __nonnull)serviceID;
- (NSString * __nonnull)serviceCardValueForServiceID:(NSString * __nonnull)serviceID;

@end
