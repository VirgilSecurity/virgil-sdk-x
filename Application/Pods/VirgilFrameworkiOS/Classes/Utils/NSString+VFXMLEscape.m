//
//  NSString+VFXMLEscape.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "NSString+VFXMLEscape.h"

@implementation NSString (VFXMLEscape)

+ (NSString *)stringWithPercentEscapesForString:(NSString *)srcString {
    if (nil == srcString) {
        return nil;
    }
    CFStringRef result = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)srcString, NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8);
    return CFBridgingRelease(result);
}

+ (NSString *)stringRemovePercentEscapesForString:(NSString *)srcString {
    if (nil == srcString) {
        return nil;
    }
    
    CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)srcString, CFSTR(""), kCFStringEncodingUTF8);
    return CFBridgingRelease(result);
}

@end
