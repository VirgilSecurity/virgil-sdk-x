//
//  VSSStringRepresentable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

@protocol VSSStringRepresentable <NSObject>

+ (instancetype __nullable)initWithStringValue:(NSString * __nonnull)string;

- (NSString * __nonnull)getStringValue;

@end
