//
//  NSString+VFXMLEscape.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VSSXMLEscape)

+ (NSString * __nonnull)stringWithPercentEscapesForString:(NSString * __nonnull)srcString;
+ (NSString * __nonnull)stringRemovePercentEscapesForString:(NSString* __nonnull)srcString;

@end
