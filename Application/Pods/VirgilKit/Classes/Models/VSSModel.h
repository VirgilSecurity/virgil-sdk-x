//
//  VSSModel.h
//  VirgilKit
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSerializable.h"

@interface VSSModel : NSObject <NSCopying, NSCoding, VSSSerializable>

- (NSNumber * __nonnull)isValid;

@end
