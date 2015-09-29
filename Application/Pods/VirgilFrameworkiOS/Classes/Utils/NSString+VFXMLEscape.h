//
//  NSString+VFXMLEscape.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VFXMLEscape)

+ (NSString *)stringWithPercentEscapesForString:(NSString *)srcString;
+ (NSString *)stringRemovePercentEscapesForString:(NSString*)srcString;

@end
