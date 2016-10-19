//
//  VSSServiceConfig.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardValidator.h"

/**
 * Helper class for services configuration.
 */
@interface VSSServiceConfig : NSObject <NSCopying>

@property (nonatomic, copy) NSString * __nonnull token;
/**
 Base URL for the Cards Service (Read/Write)
 */
@property (nonatomic, copy) NSURL * __nonnull cardsServiceURL;

/**
 Base URL for the Cards Service (Read only)
 */
@property (nonatomic, copy) NSURL * __nonnull cardsServiceROURL;

/**
 Validator object that validates Virgil Card genuineness
 Default value is nil
 */
@property (nonatomic, copy) VSSCardValidator * __nullable cardValidator;

/**
 * Convenient constructor.
 */
+ (VSSServiceConfig * __nonnull)serviceConfigWithToken:(NSString * __nonnull)token;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
