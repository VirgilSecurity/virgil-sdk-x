//
//  VFModel.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFSerializable.h"

@interface VFModel : NSObject <NSCopying, NSCoding, VFSerializable>

- (NSNumber * __nonnull)isValid;

@end
