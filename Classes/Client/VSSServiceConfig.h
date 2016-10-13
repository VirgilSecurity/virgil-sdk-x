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

/**
 * Convenient constructor.
 */
+ (VSSServiceConfig * __nonnull)serviceConfigWithDefaultValues;

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

@end
