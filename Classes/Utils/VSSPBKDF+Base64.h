//
//  VSSPBKDF+Base64.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 4/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
@import VirgilFoundation;

@interface VSSPBKDF (Base64)

- (NSString * __nullable)base64KeyFromPassword:(NSString * __nonnull)password size:(size_t)size error:(NSError * __nullable * __nullable)error;

@end
