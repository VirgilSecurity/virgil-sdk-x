//
//  VSSVirgilApi.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilApiProtocol.h"
#import "VSSVirgilApiContext.h"

/**
 NSString with Error Domain used for VSSVirgilApi-related errors
 */
extern NSString * __nonnull const kVSSVirgilApiErrorDomain;

@interface VSSVirgilApi : NSObject <VSSVirgilApi>

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithToken:(NSString * __nullable)token;

@end
